# This is a sample commands.py.  You can add your own commands here.
#
# Please refer to commands_full.py for all the default commands and a complete
# documentation.  Do NOT add them all here, or you may end up with defunct
# commands when upgrading ranger.

# A simple command for demonstration purposes follows.
# -----------------------------------------------------------------------------

from __future__ import absolute_import, division, print_function

import os
import subprocess

from ranger.api.commands import Command

# You can import any python module as needed.

# You always need to import ranger.api.commands here to get the Command class:


class fzf_select(Command):
	"""
	:fzf_select

	Find a file using fzf.

	With a prefix argument select only directories.

	See: https://github.com/junegunn/fzf
	"""
	def execute(self):
		fzf = self.fm.execute_command("fzf +m", universal_newlines=True, stdout=subprocess.PIPE)
		stdout, stderr = fzf.communicate()
		if fzf.returncode == 0:
			fzf_file = os.path.abspath(stdout.rstrip('\n'))
			if os.path.isdir(fzf_file):
				self.fm.cd(fzf_file)
			else:
				self.fm.select_file(fzf_file)
