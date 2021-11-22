from tkinter import Tk, Button, Text, INSERT, Label
import pyperclip
import sys

# Python program to create a close button
# using destroy Class method

# Class for tkinter window

FONT = 'DejaVuSansMono 32'


class Window():
	def __init__(self):

		# Creating the tkinter Window
		self.root = Tk()
		self.root.option_add('*Font', FONT)

		textarea = Label(self.root, text="Project-Text")
		textarea.pack(pady=30)

		mainarea = Text(self.root, height=10, font="DejaVuSansMono 32")
		mainarea.insert(INSERT, pyperclip.paste() or '\n'.join(sys.stdin.readlines()))
		mainarea.option_add("*Font", FONT)
		mainarea.pack(pady=30)

		# Button for closing
		exit_button = Button(self.root, text="Exit", command=self.root.destroy)
		exit_button.pack(pady=30)

		self.root.mainloop()


Window()
