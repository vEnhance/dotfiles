import re
from datetime import date as _date
from datetime import datetime, timedelta
from pprint import pprint
from typing import Any

from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

today = _date.today
rows_for_csv: list[Any] = []

with get_session() as session:
    bank = get_account(session, "A:BANK:BOA")
    recent_txn = [
        txn for txn in bank.transactions if txn.date >= today() + timedelta(days=-90)
    ]
    args_txn_to_create: list[TxnAddArgsDict] = []

    with open("/home/evan/dotfiles/gnucash-txn-import/data/boa.txt") as txtfile:
        for line in txtfile:
            if not line.strip():
                continue
            if not line[0].isdigit():
                continue
            if "Beginning balance" in line:
                continue
            str_date, str_desc, str_amount, _ = re.split(r" {2,}", line.strip())

            row_amount = to_dollars(str_amount)
            row_date = datetime.strptime(str_date, "%m/%d/%Y").date()
            row_description = str_desc

            if row_date < today() + timedelta(days=-90):
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
                if (
                    row_description.upper()
                    == "BANK OF AMERICA CREDIT CARD BILL PAYMENT"
                ):
                    row_description = "Payment for " + (
                        row_date + timedelta(days=-30)
                    ).strftime("%b 26, %Y")
                    account_name = "L:BOACC"
                elif row_description.startswith("VENMO DES:PAYMENT"):
                    row_description = "[TODO] Venmo payment"
                    account_name = "Orphan-USD"
                elif row_description.startswith("VENMO DES:CASHOUT"):
                    row_description = "Transfer Venmo -> BOA"
                    account_name = "A:Venmo"
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

with open("data/auto-gen-boa.csv", "w") as f:
    print("description,amount,date", file=f)
    for row in rows_for_csv:
        print(",".join(str(_) for _ in row), file=f)
