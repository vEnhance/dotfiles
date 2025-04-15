import csv
from datetime import date as _date
from datetime import datetime, timedelta
from pprint import pprint

from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

today = _date.today
NUM_DAYS_BACK = 180

with get_session() as session:
    citi = get_account(session, "L:Citi")

    recent_txn = [
        txn
        for txn in citi.transactions
        if txn.date >= today() + timedelta(days=-(NUM_DAYS_BACK + 2))
    ]

    args_txn_to_create: list[TxnAddArgsDict] = []
    with open("/home/evan/dotfiles/gnucash-txn-import/data/citi.csv") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            row_amount = -to_dollars(row["Debit"] or row["Credit"])
            row_date = datetime.strptime(row["Date"], "%m/%d/%Y").date()
            row_description = row["Description"].strip().title()

            if row_date < today() + timedelta(days=-NUM_DAYS_BACK):
                continue

            for txn in recent_txn:
                if (
                    abs(row_date - txn.date) <= timedelta(days=1)
                    and row_amount == txn.amount
                ) or (
                    abs(row_date - txn.date) <= timedelta(days=5)
                    and row_amount == txn.amount < 0
                ):
                    print(
                        f"Handled {row_description} from {row_date} (amount {row_amount})"
                    )
                    break
            else:
                if "Pythonanywhere" in row_description and row_amount < 0:
                    account_name = "E:Work:Web"
                    row_description = "PythonAnywhere"
                elif row_description.startswith("Autopay") and row_amount > 0:
                    account_name = "A:BANK:TCS"
                    row_description = "Autopay for " + row_date.strftime("%b %Y")
                elif (
                    row_description.startswith("Uber Eats")
                    or row_description.startswith("Uber *eats")
                ) and row_amount < 0:
                    account_name = "E:Life:Food"
                    row_description = "Uber Eats (TODO)"
                elif (
                    row_description.startswith("Uber Trip")
                    or row_description.startswith("Uber *Trip")
                    or row_description.startswith("Uber* Trip")
                ) and row_amount < 0:
                    account_name = "E:Transp:Uber"
                elif row_description.startswith("Starry") and row_amount < 0:
                    account_name = "E:House:Util"
                    row_description = "Starry Internet"
                elif row_description.startswith("Sp Soylent") and row_amount < 0:
                    account_name = "E:Life:Soylent"
                    row_description = "Soylent"
                elif (
                    row_description.startswith("Itch.io - Game Store San Francisco")
                    and row_amount == -14.99
                ):
                    account_name = "E:Work:Incidentals"
                    description = "Baba Is You key"
                elif row_description.startswith("Star Market") and row_amount < 0:
                    account_name = "E:Life:Groceries"
                    row_description = "Star Market"
                elif row_description.startswith("Wholefds Crp") and row_amount < 0:
                    account_name = "E:Life:Groceries"
                    row_description = "Whole Foods"
                elif row_description.startswith("Steam Purchase") and row_amount < 0:
                    account_name = "E:Extra:VidGame"
                    row_description = "Steam Purchase (TODO)"
                elif (
                    row_description.startswith("Github San Francisco Ca")
                    and row_amount == -7
                ):
                    account_name = "E:Donate"
                    row_description = "Sponsor TaskWarrior"
                elif row_description.startswith("Cvs/Pharmacy") and row_amount < 0:
                    account_name = "E:Life:Medical"
                    row_description = "CVS drugs"
                elif (
                    row_description.startswith("Mit Dining Cafe Qps Cambridge")
                    and row_amount < 0
                ):
                    account_name = "E:Life:Food"
                    row_description = "Stata grill of sorts"
                elif row_description.startswith("Clipper Systems") and row_amount < 0:
                    account_name = "E:Transp:Ground"
                    row_description = "BART reload card"
                elif row_description.startswith("Lyft") and row_amount < 0:
                    account_name = "E:Transp:Lyft"
                elif row_description.startswith("Mbta") and row_amount < 0:
                    account_name = "E:Transp:T"
                elif row_description.startswith("Patreon") and row_amount < 0:
                    account_name = "E:Donate"
                else:
                    account_name = "Orphan-USD"

                if (
                    row_description[:-4].endswith("Xxxxxxxxxxxx")
                    and row_description[-4:].isdigit()
                ):
                    row_description = row_description[:-17].strip()
                if row_description.endswith("Null"):
                    row_description = row_description[:-4].strip()
                if row_description.endswith("Digital Account Number"):
                    row_description = row_description[:-22].strip()

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
                citi.add(**args_dict)
