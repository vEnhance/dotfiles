"""Work-A-Holic (WAH)
for that feeling of "WAH, how did I spend 200 hours on this?"

Adapted from https://github.com/acoomans/gittime

Work in progress
"""

import sys
import yaml
from colorama import init, Fore, Style, Back
from git import Repo
from git.objects.commit import Commit # typing
from pathlib import Path
from typing import Dict
import datetime

DATE_STRING = '%a %b%d %H:%M'

init()

def pretty_print_commit(
		commit : Commit,
		time_color : str,
		time_symbol : str,
		time_delta : datetime.timedelta
		):
	num_insertions = commit.stats.total['insertions']
	num_deletions = commit.stats.total['deletions']
	if time_delta > datetime.timedelta(hours=10):
		time_symbol = ''
	print(
		Fore.YELLOW + commit.hexsha[0:6],
		Style.RESET_ALL + commit.committed_datetime.strftime(DATE_STRING),
		time_color + time_symbol + str(time_delta) + Style.RESET_ALL,
		Style.RESET_ALL + f'+{num_insertions:4d} -{num_deletions:4d}',
		Fore.CYAN + commit.summary[0:60] + Style.RESET_ALL,
	)

if __name__ == '__main__':
	committers = []
	if len(sys.argv) == 1:
		repo_path = Path('.')
	else:
		repo_path = Path(sys.argv[1])
	save_path = repo_path / '.git/wah'
	repo = Repo(repo_path)
	committers = sys.argv[2:]

	commits = [commit for commit in repo.iter_commits('main') \
			if (not committers) or (commit.committer.email in committers)]
	commits.sort(key = lambda commit : commit.committed_datetime)
	if len(commits) <= 1:
		print('haha nice try')
		sys.exit()

	# read wah data
	if save_path.exists():
		data = yaml.load(save_path.read_text(), Loader=yaml.FullLoader)
	else:
		data = {
				'min' : float(input('Default min hours threshold? [default 1] ') or '1'),
				'max' : float(input('Default max hours threshold? [default 4] ') or '4'),
				'decision' : {}
				}

	min_hours : float = data['min']
	max_hours : float = data['max']
	decision : Dict[str, bool] = data['decision'] # hexsha -> true or false
	print(Fore.CYAN + Style.BRIGHT + "Min time: " \
			+ Style.RESET_ALL + str(min_hours) + " hours")
	print(Fore.CYAN + Style.BRIGHT + "Max time: " \
			+ Style.RESET_ALL + str(max_hours) + " hours")

	time = datetime.timedelta(hours = 0)
	print('Root commit was at' + commits[0].committed_datetime.strftime(DATE_STRING))
	for i in range(len(commits)-1):
		a = commits[i]
		b = commits[i+1]
		delta : datetime.timedelta = b.committed_datetime - a.committed_datetime
		hours = delta.total_seconds() / 3600

		if b.hexsha in decision:
			if decision[b.hexsha] is True:
				time += delta
				time_color = Back.GREEN + Fore.WHITE 
				time_symbol = '+'
			else:
				time_color = Back.RED + Fore.WHITE
				time_symbol = ' '
		elif delta < datetime.timedelta(hours=min_hours):
			time += delta
			time_color = Fore.GREEN
			time_symbol = '+'
		elif delta > datetime.timedelta(hours=max_hours):
			time_color = Fore.RED
			time_symbol = ' '
			pass # do nothing
		else:
			print("Decision needed...")
			print(f"The next few commits are:")
			for j in range(i+1, min(i+5, len(commits)-1)):
				c = commits[j]
				pretty_print_commit(c,
					Fore.LIGHTYELLOW_EX,
					' ',
					c.committed_datetime - commits[j-1].committed_datetime
				)
			print(f'......  which starts {delta} later.')
			while (response := input('Is this part of the previous session? [y/n] ')\
					.lower().strip()[0:1]) not in ('y', 'n'):
				pass
			print('-'*60)
			decision[b.hexsha] = (response == 'y')
			if decision[b.hexsha]:
				time += delta
				time_color = Fore.LIGHTGREEN_EX 
				time_symbol = '+'
			else:
				time_color = Fore.LIGHTMAGENTA_EX 
				time_symbol = ' '
			save_path.write_text(yaml.dump(data)) # commit the new change immediately
		pretty_print_commit(b, time_color, time_symbol, delta)

	print(f"TOTAL HOURS: {time.total_seconds() / 3600:.2f}")
