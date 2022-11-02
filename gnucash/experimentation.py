from gnucash import Session, SessionOpenMode

from gnucash_api import get_account

with Session('../gnucash/main.gnucash', SessionOpenMode.SESSION_NORMAL_OPEN) as s:
	book = s.book

	amazon = get_account(book, 'A:AmznBal')
	goods = get_account(book, 'E:Extra:Goods')

	for txn in amazon.transactions:
		print(txn.amount, txn.cause, txn.effect, txn.description)
