"""Work-A-Holic (WAH)
for that feeling of "WAH, how did I spend 200 hours on this?"

Adapted from https://github.com/acoomans/gittime

Work in progress
"""

import argparse
import yaml
from colorama import init, Fore, Style, Back
from git import Repo
from git.objects.commit import Commit # typing
from pathlib import Path
from typing import List, Dict
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

def save(path, data):
	path.write_text(yaml.dump(data))

if __name__ == '__main__':
	parser = argparse.ArgumentParser('wah',
			description = 'Gives a crappy estimation of ' \
			'how long you wasted on this crappy code ;)',
			epilog = 'Brought to you by Evan Chen'
			)
	parser.add_argument('repo', nargs='?', default = '.',
			help = 'Path of the git repository you want to run on '
			'(defaults to current directory).')
	parser.add_argument('-e', '--emails', nargs = '+', default = [],
			help = "The list of emails to use (filter by a committer).")
	parser.add_argument('-t', '--min-time',
			help = "Assume any interval less than this counts.")
	parser.add_argument('-T', '--max-time',
			help = "Assume any interval more than this doesn't count.")
	parser.add_argument('-l', '--min-lpm',
			help = "The minimum lines/minute expected when working over min_time.")
	parser.add_argument('-L', '--max-lpm',
			help = "Assume that any lines/minutes exceeding this counts.")
	parser.add_argument('-w', '--write',
			help = "Store the values of the [lLtT] flags into the WAH file " \
					"so you don't have to put them again later.")

	input_group = parser.add_mutually_exclusive_group()
	input_group.add_argument('-i', '--interactive', action='store_true',
			help = "In cases not covered by heuristics, ask the user.")
	input_group.add_argument('-n', '--no', action='store_true',
			help = "In cases not covered by heuristics, assume no.")
	input_group.add_argument('-y', '--yes', action='store_true',
			help = "In cases not covered by heuristics, assume yes.")

	verbose_group = parser.add_mutually_exclusive_group()
	verbose_group.add_argument('-v', '--verbose', action = 'store_true',
			help = "Verbose mode: print commit messages and notes.")
	verbose_group.add_argument('-q', '--quiet', action = 'store_true',
			help = "Quiet mode: don't print stuff if not necessary.")

	args = parser.parse_args()
	repo_path = Path(args.repo)
	committers : List[str] = args.emails
	repo = Repo(args.repo)
	save_path = repo_path / '.git/wah'

	commits = [commit for commit in repo.iter_commits('main') \
			if (not committers) or (commit.committer.email in committers)]
	commits.sort(key = lambda commit : commit.committed_datetime)

	# read wah data
	needs_save = False
	if save_path.exists():
		data = yaml.load(save_path.read_text(), Loader=yaml.SafeLoader)
	else:
		data = {
				'min_hours' : None,
				'max_hours' : None,
				'min_lpm' : None,
				'max_lpm' : None,
				'decision' : {}
				}
		needs_save = True
	if args.min_time is not None:
		data['min_hours'] = args.min_time
		needs_save = True
	if args.max_time is not None:
		data['max_hours'] = args.max_hours
		needs_save = True
	if args.min_time is not None:
		data['min_lpm'] = args.min_lpm
		needs_save = True
	if args.min_time is not None:
		data['max_lpm'] = args.max_lpm
		needs_save = True
	if needs_save is True:
		save(save_path, data)

	min_hours : float = _ if (_ := data['min_hours']) is not None else 0.75
	max_hours : float = _ if (_ := data['max_hours']) is not None else 4.0
	min_lpm : float = _ if (_ := data['min_lpm']) is not None else 0.1
	max_lpm : float = _ if (_ := data['max_lpm']) is not None else 1

	decision : Dict[str, bool] = data.get('decision', {}) # hexsha -> true or false
	time = datetime.timedelta(hours = 0)
	if args.verbose:
		print('Root commit was at ' \
				+ commits[0].committed_datetime.strftime(DATE_STRING))
	for i in range(len(commits)-1):
		a = commits[i]
		b = commits[i+1]
		delta : datetime.timedelta = b.committed_datetime - a.committed_datetime
		hours = max(delta.total_seconds() / 3600, 1.0/3600)
		minutes = hours * 60
		lines_per_minute = b.stats.total['lines'] / minutes

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
		elif lines_per_minute > max_lpm:
			time += delta
			time_color = Style.BRIGHT + Fore.GREEN
			time_symbol = '+'
		elif lines_per_minute < min_lpm:
			time_color = Style.BRIGHT + Fore.RED
			time_symbol = ' '
		else:
			if args.yes:
				this_decision = True
			elif args.no:
				this_decision = False
			else:
				print("Decision needed...\n")
				if not args.verbose:
					# need to print some context
					print("Before, we had:")
					pretty_print_commit(a,
						'',
						' ',
						a.committed_datetime - commits[i-1].committed_datetime
					)
					print("")
				print(f"The next few commits are:")
				for j in range(i+1, min(i+5, len(commits))):
					c = commits[j]
					pretty_print_commit(c,
						Fore.LIGHTYELLOW_EX,
						' ',
						c.committed_datetime - commits[j-1].committed_datetime
					)
				print(f'...... starting {delta} later.\n')
				print(f"This commit had {lines_per_minute:.5f} lines per minute.\n")
				while (response := input('Is this part of the previous session?' \
					' [y/n] ').lower().strip()[0:1]) not in ('y', 'n'):
					pass
				print('-'*60)
				this_decision = (response == 'y')
				decision[b.hexsha] = this_decision

			if this_decision is True:
				time += delta
				time_color = Fore.LIGHTGREEN_EX 
				time_symbol = '+'
			else:
				time_color = Fore.LIGHTMAGENTA_EX 
				time_symbol = ' '
			save(save_path, data)
			# commit the new change immediately
		if args.verbose:
			pretty_print_commit(b, time_color, time_symbol, delta)

	print(f"{time.total_seconds() / 3600:.2f}")
