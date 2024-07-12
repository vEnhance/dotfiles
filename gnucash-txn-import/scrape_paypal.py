from datetime import date as _date
from datetime import datetime, timedelta
from decimal import Decimal
from pprint import pprint
from typing import Any

from bs4 import BeautifulSoup
from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

today = _date.today


def get_child_string(
    div: BeautifulSoup, tag_name="div", class_name: str | None = None
) -> str:
    if class_name is None:
        elm = div.find(tag_name)
    else:
        elm = div.find(tag_name, class_=class_name)
    assert elm is not None, f"Couldn't find {tag_name} with class={class_name} in {div}"
    return " ".join(line.strip() for line in elm.strings if line.strip()).strip()


current_year = int(datetime.today().strftime("%Y"))
assert current_year > 2000

rows_for_csv: list[Any] = []
NUM_DAYS_BACK = 60

with get_session() as session:
    paypal = get_account(session, "A:Paypal")
    recent_txn = [
        txn
        for txn in paypal.transactions
        if txn.date >= today() + timedelta(days=-(NUM_DAYS_BACK + 5))
    ]
    args_txn_to_create: list[TxnAddArgsDict] = []

    with open("/home/evan/dotfiles/gnucash-txn-import/data/paypal.html") as htmlfile:
        soup = BeautifulSoup(htmlfile, features="lxml")

    for div in soup.find_all("div", class_="description_container"):
        str_amount = get_child_string(div, class_name="txn_amt_font")
        str_amount = str_amount.replace("$", "")
        str_amount = str_amount.replace(" ", "")
        str_amount = str_amount.replace("−", "-")
        row_amount = to_dollars(str_amount)
        try:
            date_blurb = get_child_string(
                div, class_name="transaction_type_text_with_notes"
            )
        except AssertionError:
            date_blurb = get_child_string(div, class_name="transaction_type_text")
        str_date = date_blurb[: date_blurb.index(".")].strip()
        row_date = datetime.strptime(f"{str_date} {current_year}", r"%b %d %Y").date()
        if row_date > _date.today():
            row_date = datetime.strptime(
                f"{str_date} {current_year-1}", r"%b %d %Y"
            ).date()
        row_description = get_child_string(
            div, tag_name="div", class_name="counterparty_name"
        )
        try:
            note = get_child_string(div, class_name="transaction_notes")
        except AssertionError:
            note = ""
        else:
            note = note.strip('"')
            if len(note) > 52:
                note = note[:48] + "..."
            row_description += ": " + note

        if row_date < today() + timedelta(days=-NUM_DAYS_BACK):
            continue
        rows_for_csv.append([row_description, row_amount, row_date])

        for txn in recent_txn:
            if (
                abs(row_date - txn.date) <= timedelta(days=1)
                and row_amount == txn.amount
            ):
                print(f"Handled {row_description} from {row_date}")
                break
        else:
            if (
                row_amount in (Decimal("-17.64"), Decimal("-31.36"), Decimal("-40.96"))
                and ": OTIS" in row_description
            ):
                account_name = "E:Work:Intern"
            else:
                account_name = "Orphan-USD"
            args_txn_to_create.append(
                {
                    "amount": row_amount,
                    "description": row_description,
                    "target": get_account(session, account_name),
                    "txn_date": row_date,
                }
            )

    pprint(args_txn_to_create)
    if len(args_txn_to_create) > 0:
        user_response = input("Continue? [y/n]: ").lower().strip()
        if user_response.startswith("y") or user_response == "":
            for args_dict in args_txn_to_create:
                paypal.add(**args_dict)

with open("data/auto-gen-paypal.csv", "w") as f:
    print("description,amount,date", file=f)
    for row in rows_for_csv:
        print(",".join(str(_) for _ in row), file=f)
