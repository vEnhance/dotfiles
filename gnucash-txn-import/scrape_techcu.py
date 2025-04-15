import csv
from datetime import date as _date
from datetime import datetime, timedelta
from pprint import pprint
from typing import Any

from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

today = _date.today
NUM_DAYS_BACK = 180


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

        csv_name = "techcu-s.csv" if bank_account_name == "TCS" else "techcu-c.csv"

        with open(f"/home/evan/dotfiles/gnucash-txn-import/data/{csv_name}") as csvfile:
            reader = csv.DictReader(csvfile)
            rows = [row for row in reader]

        for row in rows:
            row_amount = to_dollars(row["Amount"])
            str_date = row["Posting Date"]
            row_date = datetime.strptime(str_date, "%m/%d/%Y").date()
            row_description = row["Description"]

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
                if row_description.startswith("UMS OPERATING TYPE") and row_amount < 0:
                    row_description = "Water bill for " + row_date.strftime("%b %Y")
                    account_name = "E:House:Util"
                elif (
                    row_description.startswith("UTILITY MANAGEME TYPE")
                    and row_amount < 0
                ):
                    row_description = "Water bill for " + row_date.strftime("%b %Y")
                    account_name = "E:House:Util"
                elif row_description == "Payment to National Grid" and row_amount < 0:
                    row_description = "Gas bill for " + (
                        row_date + timedelta(days=-28)
                    ).strftime("%b %Y")
                    account_name = "E:House:Util"
                elif (
                    row_description == "Payment to Eversource Energy" and row_amount < 0
                ):
                    row_description = "Electricity bill for " + (
                        row_date + timedelta(days=-14)
                    ).strftime("%b %Y")
                    account_name = "E:House:Util"
                elif (
                    row_description.startswith("Tiered Rate APY Earned")
                    and row_amount > 0
                ):
                    row_description = "APY Interest"
                    account_name = "I:AntiFee"
                elif row_description == "Payment to Citibank" and row_amount < 0:
                    row_description = "Autopay for " + row_date.strftime("%b %Y")
                    account_name = "L:Citi"
                elif row_description.startswith("Twitch") and row_amount > 0:
                    row_description = "Twitch streamer payout"
                    account_name = "I:Twitch"
                elif row_description.startswith("TD BANK") and row_amount < 0:
                    row_description = "TD payment"
                    account_name = "L:TD"
                elif (
                    row_description.startswith("Transfer from Stripe")
                    and bank_account_name == "TCC"
                ):
                    row_description = "OTIS-WEB payment via Stripe API"
                    account_name = "I:OTIS:2025S"  # TODO: make this adapt
                elif "FORECASTER 121" in row_description and row_amount < 0:
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
