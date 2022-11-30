import collections
import xml.etree.ElementTree as ET
from typing import DefaultDict, List

from txn import Txn

ns = {
    "gnc": "http://www.gnucash.org/XML/gnc",
    "act": "http://www.gnucash.org/XML/act",
    "book": "http://www.gnucash.org/XML/book",
    "cd": "http://www.gnucash.org/XML/cd",
    "cmdty": "http://www.gnucash.org/XML/cmdty",
    "price": "http://www.gnucash.org/XML/price",
    "slot": "http://www.gnucash.org/XML/slot",
    "split": "http://www.gnucash.org/XML/split",
    "sx": "http://www.gnucash.org/XML/sx",
    "trn": "http://www.gnucash.org/XML/trn",
    "ts": "http://www.gnucash.org/XML/ts",
    "fs": "http://www.gnucash.org/XML/fs",
    "bgt": "http://www.gnucash.org/XML/bgt",
    "recurrence": "http://www.gnucash.org/XML/recurrence",
    "lot": "http://www.gnucash.org/XML/lot",
    "addr": "http://www.gnucash.org/XML/addr",
    "billterm": "http://www.gnucash.org/XML/billterm",
    "bt-days": "http://www.gnucash.org/XML/bt-days",
    "bt-prox": "http://www.gnucash.org/XML/bt-prox",
    "cust": "http://www.gnucash.org/XML/cust",
    "employee": "http://www.gnucash.org/XML/employee",
    "entry": "http://www.gnucash.org/XML/entry",
    "invoice": "http://www.gnucash.org/XML/invoice",
    "job": "http://www.gnucash.org/XML/job",
    "order": "http://www.gnucash.org/XML/order",
    "owner": "http://www.gnucash.org/XML/owner",
    "taxtable": "http://www.gnucash.org/XML/taxtable",
    "tte": "http://www.gnucash.org/XML/tte",
    "vendor": "http://www.gnucash.org/XML/vendor",
}

tree = ET.parse('/tmp/gnucash.xml')
root = tree.getroot()


def strip_recurring(s: str) -> str:
    months = [
        'january', 'february', 'march', 'april', 'may', 'june', 'july',
        'august', 'september', 'october', 'november', 'december'
    ]
    s = s.strip()
    for i in range(3, 10):
        for m in months:
            needle = f' for {m[:i]} 20'
            if s.lower()[:-2].endswith(needle):
                return s[:-(len(needle) + 2)].strip() + ' recurring'
    return s


# Get the account GUID's for OTIS transactions

account_guids: DefaultDict[str, list] = collections.defaultdict(list)

desired = ('Paypal', 'BOA', 'TCS', 'TCC')
book = root.find('gnc:book', ns)
assert book is not None

for account_elm in book.findall('gnc:account', ns):
    name_elm = account_elm.find('act:name', ns)
    if name_elm is not None and name_elm.text in desired:
        guid_elm = account_elm.find('act:id', ns)
        assert guid_elm is not None and guid_elm.text is not None and name_elm.text is not None
        account_guids[name_elm.text].append(guid_elm.text)

rows: List[Txn] = []

# Get all transactions
for transaction_elm in book.findall('gnc:transaction', ns):
    date_container = transaction_elm.find('trn:date-posted', ns)
    assert date_container is not None
    date = date_container.find('ts:date', ns)
    assert date is not None and date.text is not None

    splits = transaction_elm.find('trn:splits', ns)
    assert splits is not None
    assert len(splits.findall('trn:split', ns)) > 0

    for split in splits.findall('trn:split', ns):
        reconciled = split.find('split:reconciled-state', ns)
        assert reconciled is not None
        if reconciled.text == 'y':
            continue
        guid = split.find('split:account', ns)
        assert guid is not None and guid.text is not None
        for account_name in desired:
            if guid.text in account_guids[account_name]:
                description = transaction_elm.find('trn:description', ns)
                if description is None or description.text is None:
                    description_text = ''
                else:
                    description_text = description.text
                amount = split.find('split:value', ns)
                assert amount is not None and amount.text is not None
                value = eval(amount.text)

                if 'from ' in description_text and '(' in description_text and ')' in description_text:
                    i = description_text.index('from ') + 5
                    j = description_text.index(')')
                    description_text = description_text[i:j]
                elif 'via ' in description_text and '(' in description_text and ')' in description_text:
                    i = description_text.index('via ') + 4
                    j = description_text.index(')')
                    description_text = description_text[i:j]
                elif '(' in description_text:
                    description_text = description_text[:description_text.
                                                        index('(')].strip()
                description_text = strip_recurring(description_text)
                rows.append(
                    Txn(
                        f'{date.text[0:10]}',
                        account_name,
                        description_text.title(),
                        value,
                    ))

rows.sort()
for row in rows:
    print(row.csv())
