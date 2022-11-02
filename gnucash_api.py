from datetime import datetime
from decimal import Decimal
from typing import Optional, Union

from gnucash import Account, Book, GncNumeric, Split, Transaction  # NOQA


class GNCTxn:
	def __init__(self, split: Split):
		self._txn = split.parent
		self.amount = round(Decimal(float(split.GetValue())), 2)

	@property
	def description(self) -> str:
		return self._txn.GetDescription()

	@property
	def date(self) -> str:
		return self._txn.GetDate()

	@property
	def is_split(self) -> bool:
		return len(self._txn.GetSplitList()) > 2

	@property
	def cause(self) -> Optional['GNCAccount']:
		if self.is_split:
			return None
		return GNCAccount(self._txn.GetSplitList()[0].GetAccount())

	@property
	def effect(self) -> Optional['GNCAccount']:
		if self.is_split:
			return None
		return GNCAccount(self._txn.GetSplitList()[1].GetAccount())


class GNCAccount:
	def __init__(self, _account: Account):
		self._account = _account
		self.is_root = _account.get_parent() is None

	def __str__(self):
		if self.is_root:
			return None
		parent = GNCAccount(self._account.get_parent())
		name = self._account.GetName()
		if parent.is_root:
			return name
		else:
			return f'{parent}:{name}'

	@property
	def transactions(self) -> list[GNCTxn]:
		return [GNCTxn(split) for split in self._account.GetSplitList()]

	def add(
		self,
		description: str,
		amount: Union[Decimal, int, float],
		target: 'GNCAccount',
		date: Optional[datetime] = None,
	):
		book = self._account.GetBook()
		currency = book.get_table().lookup("CURRENCY", "USD")
		if date is None:
			date = datetime.now()

		trans = Transaction(book)
		trans.BeginEdit()
		trans.SetCurrency(currency)
		trans.SetDate(date.day, date.month, date.year)
		trans.SetDescription(description)

		split1 = Split(book)
		split1.SetValue(GncNumeric(amount))
		split1.SetAccount(self._account)
		split1.SetParent(trans)

		split2 = Split(book)
		split2.SetValue(GncNumeric(-amount))
		split2.SetAccount(target._account)
		split2.SetParent(trans)

		trans.CommitEdit()
		return GNCTxn(split1)


def get_account(book: Book, account_name: str) -> GNCAccount:
	account = book.get_root_account()
	for chunk in account_name.split(':'):
		account = account.lookup_by_name(chunk)
		assert account is not None, f'On {chunk} of {account_name}'
	return GNCAccount(account)
