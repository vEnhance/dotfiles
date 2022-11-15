from gnucash import Session, SessionOpenMode
from gnucash_api import get_account

GNUCASH_PATH = '/home/evan/Sync/Grownup/Finance/gnucash/main.gnucash'
with Session(GNUCASH_PATH, SessionOpenMode.SESSION_NORMAL_OPEN) as s:
    book = s.book

    amazon = get_account(book, 'A:AmznBal')
    goods = get_account(book, 'E:Extra:Goods')

    for txn in amazon.transactions:
        print(txn.amount, txn.cause, txn.effect, txn.description)
