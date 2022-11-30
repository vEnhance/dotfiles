from datetime import date
from functools import total_ordering
from typing import Tuple, Union


@total_ordering
class Txn:

    def __init__(self, dt: Union[str, date], key: str, sender: str,
                 value: float):
        if isinstance(dt, str):
            self.dt = date.fromisoformat(dt)
        else:
            self.dt = dt
        self.key = key.strip()
        self.sender = sender.title()
        self.value = value

    def __repr__(self) -> str:
        return self.sender

    def csv(self) -> str:
        return f'{self.key},{self.sender},{self.value:.2f}'

    def sortkey(self) -> Tuple[str, float, str, date]:
        return (self.key, self.value, self.sender, self.dt)

    def __lt__(self, other: 'Txn'):
        return self.sortkey() < other.sortkey()

    def __eq__(self, other: object):
        if not isinstance(other, Txn):
            return False
        return self.sortkey() == other.sortkey()
