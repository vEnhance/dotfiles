#!/bin/python
"""
pɹɑdʒɪ̈kt tɛkst"

This trivial script displays the clipboard contents in a large font. It is meant for use when you want to copy some text from your computer to your iDevice.

By default, it reads from standard input.
If there is no standard input, it uses clipboard contents.

"""

from tkinter import Tk, Button, Text, INSERT, Label
import pyperclip
import sys

# Python program to create a close button
# using destroy Class method

# Class for tkinter window
FONT = 'DejaVuSansMono 36'


class Window():
	def __init__(self):

		# Creating the tkinter Window
		self.root = Tk()
		self.root.option_add('*Font', FONT)

		textarea = Label(self.root, text="pɹɑdʒɪ̈kt tɛkst", foreground='blue')
		textarea.pack(pady=15)

		mainarea = Text(self.root, height=6, font="DejaVuSansMono 72")
		mainarea.insert(
			INSERT, '\n'.join(sys.stdin.readlines()) or pyperclip.paste() or "Type text here..."
		)

		mainarea.option_add("*Font", FONT)
		mainarea.pack(pady=15)

		# Button for closing
		exit_button = Button(
			self.root,
			text="Exit",
			command=self.root.destroy,
			background='red',
			activebackground='orange'
		)
		exit_button.pack(pady=10)

		self.root.mainloop()


Window()
