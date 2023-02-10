import re
import sys
from csv import DictReader
from typing import List

from txn import Txn
from unidecode import unidecode

transactions: List[Txn] = []


def convert_to_dashes(s: str) -> str:
    month, day, year = [int(_) for _ in s.split("/")]
    return f"{year:04d}-{month:02d}-{day:02d}"


last_sender = ""
with open("data/paypal.csv") as csvfile:
    reader = DictReader(csvfile)
    for row in reader:
        slash_date = row['\ufeff"Date"']
        sender = unidecode(row["Name"]).title()
        if row["Type"] == "General Currency Conversion":
            if row["Currency"] == "USD":
                sender = last_sender
            else:
                continue
        elif row["Currency"] != "USD":
            last_sender = sender
            continue
        elif sender != "Paypal":
            if "amount" in row:
                amount_str = row["amount"]
            elif "Amount" in row:
                amount_str = row["Amount"]
            else:
                print(f"No amount in {row}", file=sys.stderr)
                continue
            transactions.append(
                Txn(
                    dt=convert_to_dashes(slash_date),
                    key="Paypal",
                    sender=sender,
                    value=float(amount_str.replace(",", "")),
                )
            )

with open("data/auto-gen-techcu.csv") as csvfile:
    reader = DictReader(csvfile)
    for row in reader:
        note = row["description"]
        amount = float(row["amount"])

        if round(amount) == 1000 and note == "Transfer Withdrawal":
            sender = "Mortgage contribution to parents"
        elif note == "ACH Withdrawal EVERSOURCE":
            sender = "Electricity bill recurring"
        elif note == "ACH Withdrawal UTILITY MGMT SOL":
            sender = "Water bill recurring"
        elif note == "ACH Withdrawal NATIONAL GRID NE":
            sender = "Gas bill recurring"
        elif note == "ACH Deposit STRIPE":
            sender = "Stripe"
        elif note == "ACH Deposit MASS INST":
            sender = "MIT direct deposit"
        elif note == "ACH Withdrawal CITI AUTOPAY":
            sender = "Autopay recurring"
        elif note == "ACH Withdrawal TD BANK":
            sender = "TD payment"
        else:
            sender = note

        transactions.append(
            Txn(
                dt=row["date"],
                key="TCS",
                sender=sender,
                value=amount,
            )
        )

boa_regex = re.compile(
    r"(?P<date>[0-9\/]{10}) +(?P<description>.+)  (?P<amount>-?[,0-9]+\.[0-9][0-9]) +(-?[,0-9]+\.[0-9][0-9])"
)
with open("data/boa.txt") as f:
    for line in f:
        m = boa_regex.fullmatch(line.strip())
        if m is not None:
            x = m.group("description").strip()
            if ";" in x:
                x = x[x.rindex(";") + 1 :].strip()
            if x.count(",") == 1:
                lname, fname = x.split(",")
                x = fname.strip() + " " + lname.strip()
            if "DEPOSIT" in x:
                x = "Check deposit"
            if "BANK OF AMERICA CREDIT CARD" in x:
                x = "Payment recurring"
            transactions.append(
                Txn(
                    dt=convert_to_dashes(m.group("date")),
                    key="BOA",
                    sender=x,
                    value=float(m.group("amount").replace(",", "")),
                )
            )

transactions.sort()
for txn in transactions:
    print(txn.csv())
