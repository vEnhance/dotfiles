from datetime import date
from decimal import Decimal
from typing import Optional, Union

from gnucash import Account, GncNumeric, Session, SessionOpenMode, Split, Transaction  # NOQA


def to_dollars(x: Union[str, int, float, Decimal, GncNumeric]) -> Decimal:
	if type(x) == GncNumeric:
		x = float(x)
	return round(Decimal(float(x)), 2)


class GNCTxn:
	def __init__(self, split: Split):
		self._split = split
		self._txn = split.parent
		self.amount = to_dollars(split.GetValue())
		self.reconciled = (split.GetReconcile() == 'y')

	def __repr__(self):
		return str(self)

	def __str__(self):
		return self.description

	@property
	def description(self) -> str:
		return self._txn.GetDescription()

	@property
	def date(self) -> date:
		return self._txn.GetDate().date()

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

	def __repr__(self):
		return str(self)

	def __str__(self):
		if self.is_root:
			return 'ROOT'
		parent = GNCAccount(self._account.get_parent())
		name = self._account.GetName()
		if parent.is_root:
			return name
		else:
			return f'{str(parent)}:{name}'

	@property
	def transactions(self) -> list[GNCTxn]:
		return [GNCTxn(split) for split in self._account.GetSplitList()]

	def add(
		self,
		amount: Union[Decimal, int, float],
		description: str,
		target: 'GNCAccount',
		txn_date: date = date.today(),  # sigh
	):
		book = self._account.get_book()
		currency = book.get_table().lookup("CURRENCY", "USD")

		trans = Transaction(book)
		trans.BeginEdit()
		trans.SetCurrency(currency)
		trans.SetDate(txn_date.day, txn_date.month, txn_date.year)
		trans.SetDescription(description)

		split1 = Split(book)
		split1.SetValue(GncNumeric(str(amount)))
		split1.SetAccount(self._account)
		split1.SetParent(trans)

		split2 = Split(book)
		split2.SetValue(GncNumeric(str(-amount)))
		split2.SetAccount(target._account)
		split2.SetParent(trans)

		trans.CommitEdit()
		return GNCTxn(split1)


def get_account(session: Session, account_name: str) -> GNCAccount:
	book = session.book
	account = book.get_root_account()
	for chunk in account_name.split(':'):
		account = account.lookup_by_name(chunk)
		assert account is not None, f'On {chunk} of {account_name}'
	return GNCAccount(account)


DEFAULT_PATH = '/home/evan/Sync/Grownup/Finance/gnucash/main.gnucash'


def get_session(path: str = DEFAULT_PATH) -> Session:
	return Session(path, SessionOpenMode.SESSION_NORMAL_OPEN)
