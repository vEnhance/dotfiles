import csv
from datetime import date as _date
from datetime import datetime, timedelta
from pprint import pprint

today = _date.today

from gnucash_api import TxnAddArgsDict, get_account, get_session, to_dollars

with get_session() as session:
	citi = get_account(session, 'L:Citi')

	recent_txn = [txn for txn in citi.transactions if txn.date >= today() + timedelta(days=-60)]

	args_txn_to_create: list[TxnAddArgsDict] = []
	with open('/home/evan/Sync/Grownup/Finance/txn-importer/Citi.csv') as csvfile:
		reader = csv.DictReader(csvfile)
		for row in reader:
			row_amount = -to_dollars(row['Debit'] or row['Credit'])
			row_date = datetime.strptime(row['Date'], '%m/%d/%Y').date()
			row_description = row['Description'].strip().title()

			if row_date < today() + timedelta(days=-60):
				continue

			for txn in recent_txn:
				if abs(row_date - txn.date) <= timedelta(days=1) and row_amount == txn.amount:
					print(f"Handled {row_description} from {row_date}")
					break
			else:
				if 'Pythonanywhere' in row_description and row_amount < 0:
					account_name = 'E:Work:Web'
					row_description = 'PythonAnywhere'
				elif row_description.startswith('Autopay') and row_amount > 0:
					account_name = 'A:BANK:TCS'
					row_description = 'Autopay for ' + row_date.strftime('%b %Y')
				elif (
					row_description.startswith('Uber Eats') or row_description.startswith('Uber *eats')
				) and row_amount < 0:
					account_name = 'E:Life:Food'
					row_description = 'Uber Eats (TODO)'
				elif row_description.startswith('Starry Plus Boston Ma') and row_amount < 0:
					account_name = 'E:House:Util'
					row_description = 'Starry Internet'
				elif row_description.startswith('Sp Soylent') and row_amount < 0:
					account_name = 'E:Life:Soylent'
					row_description = 'Soylent'
				elif row_description.startswith(
					'Itch.io - Game Store San Francisco'
				) and row_amount == -14.99:
					account_name = 'E:Work:Incidentals'
					description = 'Baba Is You key'
				elif row_description.startswith('Star Market') and row_amount < 0:
					account_name = 'E:Life:Groceries'
					row_description = 'Star Market'
				elif row_description.startswith('Wholefds Crp') and row_amount < 0:
					account_name = 'E:Life:Groceries'
					row_description = 'Whole Foods'
				elif row_description.startswith('Steam Purchase') and row_amount < 0:
					account_name = 'E:Extra:VidGame'
					row_description = 'Steam Purchase (TODO)'
				elif row_description.startswith('Github San Francisco Ca') and row_amount == -7:
					account_name = 'E:Donate'
					row_description = 'Sponsor TaskWarrior'
				elif row_description.startswith('Cvs/Pharmacy') and row_amount < 0:
					account_name = 'E:Life:Medical'
					row_description = 'CVS drugs'
				elif row_description.startswith('Mit Dining Cafe Qps Cambridge') and row_amount < 0:
					account_name = 'E:Life:Food'
					row_description = 'Stata grill of sorts'
				else:
					account_name = 'Orphan-USD'

				args_txn_to_create.append(
					{
						'amount': row_amount,
						'description': row_description,
						'target': get_account(session, account_name),
						'txn_date': row_date,
					}
				)

	pprint(args_txn_to_create)
	if len(args_txn_to_create) > 0:
		user_response = input('Continue? [y/n]: ').lower().strip()
		if user_response.startswith('y') or user_response == '':
			for args_dict in args_txn_to_create:
				citi.add(**args_dict)
