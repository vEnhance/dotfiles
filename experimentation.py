from decimal import Decimal
from typing import Union

from gnucash import Account, Book, GncNumeric, Session, SessionOpenMode, Split, Transaction  # NOQA


def get_account(book: Book, account_name: str) -> Account:
	account = book.get_root_account()
	for chunk in account_name.split(':'):
		account = account.lookup_by_name(chunk)
		assert account is not None, f'On {chunk} of {account_name}'
	return account


def add_txn(
	book: Book,
	description: str,
	amount: Union[Decimal, int, float],
	from_account: Account,
	to_account: Account,
):
	currency = book.get_table().lookup("CURRENCY", "USD")

	trans = Transaction(book)
	trans.BeginEdit()
	trans.SetCurrency(currency)
	trans.SetDate(1, 11, 2022)
	trans.SetDescription(description)

	split1 = Split(book)
	split1.SetValue(GncNumeric(amount))
	split1.SetAccount(from_account)
	split1.SetParent(trans)

	split2 = Split(book)
	split2.SetValue(GncNumeric(-amount))
	split2.SetAccount(to_account)
	split2.SetParent(trans)

	trans.CommitEdit()


with Session('../gnucash/main.gnucash', SessionOpenMode.SESSION_NORMAL_OPEN) as s:
	book = s.book

	amazon = get_account(book, 'A:AmznBal')
	goods = get_account(book, 'E:Extra:Goods')
	add_txn(book, description='Toy', amount=1, from_account=amazon, to_account=goods)

	for split in amazon.GetSplitList():
		print(split.parent.GetDescription())
