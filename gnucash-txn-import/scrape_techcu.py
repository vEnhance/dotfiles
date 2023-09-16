from datetime import date as _date
from datetime import datetime, timedelta
from pprint import pprint
from typing import Any

from bs4 import BeautifulSoup

today = _date.today

from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

NUM_DAYS_BACK = 90


def get_child_string(
    tr: BeautifulSoup, tag_name="td", class_name: str | None = None
) -> str:
    if class_name is None:
        elm = tr.find(tag_name)
    else:
        elm = tr.find(tag_name, class_=class_name)
    assert elm is not None, f"Couldn't find {tag_name} with class {class_name} in {tr}"
    return " ".join(line.strip() for line in elm.strings if line.strip()).strip()


rows_for_csv: list[Any] = []

with get_session() as session:
    for bank_account_name in ("TCS", "TCC"):
        bank = get_account(session, f"A:BANK:{bank_account_name}")
        recent_txn = [
            txn
            for txn in bank.transactions
            if txn.date >= today() + timedelta(days=-(NUM_DAYS_BACK + 2))
        ]
        args_txn_to_create: list[TxnAddArgsDict] = []

        with open(
            "/home/evan/dotfiles/gnucash-txn-import/data/techcu.html"
        ) as htmlfile:
            soup = BeautifulSoup(htmlfile, features="lxml")

        for tr in soup.find_all("tr", class_="Data"):
            # first check if this is even the right account
            if bank_account_name == "TCC":
                if "CLICK CHECKING" not in "".join(tr.strings):
                    continue
            if bank_account_name == "TCS":
                if "STUDENT SAVINGS ACCOUNT" not in "".join(tr.strings):
                    continue

            str_amount = get_child_string(tr, "td", "Number").replace(",", "")
            row_amount = (
                -to_dollars(str_amount[2:-1])
                if str_amount.startswith("(")
                else to_dollars(str_amount[1:])
            )
            str_date = get_child_string(tr, "td", "Word")
            row_date = datetime.strptime(str_date, "%m/%d/%Y").date()
            row_description = get_child_string(tr, "b")

            if row_date < today() + timedelta(days=-NUM_DAYS_BACK):
                continue

            rows_for_csv.append([row_description, row_amount, row_date])

            for txn in recent_txn:
                if (
                    abs(row_date - txn.date) <= timedelta(days=2)
                    and row_amount == txn.amount
                ):
                    print(f"Handled {row_description} from {row_date}")
                    break
            else:
                if row_description == "ACH Deposit MASS INST" and row_amount > 0:
                    row_description = "MIT direct deposit"
                    account_name = "I:MIT"
                elif (
                    row_description.startswith("ACH Withdrawal UTILITY M")
                    and row_amount < 0
                ):
                    row_description = "Water bill for " + row_date.strftime("%b %Y")
                    account_name = "E:House:Util"
                elif (
                    row_description == "ACH Withdrawal NATIONAL GRID NE"
                    and row_amount < 0
                ):
                    row_description = "Gas bill for " + (
                        row_date + timedelta(days=-28)
                    ).strftime("%b %Y")
                    account_name = "E:House:Util"
                elif row_description == "ACH Withdrawal EVERSOURCE" and row_amount < 0:
                    row_description = "Electricity bill for " + (
                        row_date + timedelta(days=-14)
                    ).strftime("%b %Y")
                    account_name = "E:House:Util"
                elif (
                    row_description == "Transfer Withdrawal"
                    and row_amount == -1000
                    and row_date.day < 7
                ):
                    row_description = "Mortgage contribution to parents"
                    account_name = "E:House:Mortg"
                elif (
                    row_description == "Dividend Deposit Tiered Rate" and row_amount > 0
                ):
                    row_description = "APY Interest"
                    account_name = "I:AntiFee"
                elif (
                    row_description == "ACH Withdrawal CITI AUTOPAY" and row_amount < 0
                ):
                    row_description = "Autopay for " + row_date.strftime("%b %Y")
                    account_name = "L:Citi"
                elif (
                    row_description.startswith("ACH Deposit Twitch") and row_amount > 0
                ):
                    row_description = "Twitch streamer payout"
                    account_name = "I:Twitch"
                elif (
                    row_description.startswith("ACH Withdrawal TD BANK")
                    and row_amount < 0
                ):
                    row_description = "TD payment"
                    account_name = "L:TD"
                elif (
                    row_description == "ACH Deposit STRIPE"
                    and bank_account_name == "TCC"
                ):
                    row_description = "OTIS-WEB payment via Stripe API"
                    account_name = "I:OTIS:2024S"  # TODO: make this adapt
                elif "Forecaster 121" in row_description and row_amount < 0:
                    row_description = "Forecaster 121 HOA"
                    account_name = "E:House:HOA"
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
                    bank.add(**args_dict)

with open("data/auto-gen-techcu.csv", "w") as f:
    print("description,amount,date", file=f)
    for row in rows_for_csv:
        print(",".join(str(_) for _ in row), file=f)
