##########
## TSQX ##
##########

# original TSQX by CJ Quines: https://github.com/cjquines/tsqx
# original TSQ by evan chen

import enum, re, sys


def generate_points(kind, n):
	if kind == "triangle":
		return ["dir(110)", "dir(210)", "dir(330)"]
	elif kind == "regular":
		return [f"dir({(90 + i*360/n) % 360})" for i in range(n)]
	raise SyntaxError("Special command not recognized")


class Op:
	def _join_exp(self, exp, join_str):
		return join_str.join(self._emit_exp(e) for e in exp)

	def _emit_exp(self, exp):
		if not isinstance(exp, list):
			return exp
		if "," in exp:
			return f"({self._join_exp(exp, ' ')})"
		head, *tail = exp
		if not tail:
			return head
		if tail[0] in ["--", "..", "^^"]:
			return self._join_exp(exp, ", ")
		return f"{head}({self._join_exp(tail, ', ')})"

	def emit_exp(self):
		res = self._join_exp(self.exp, "*")
		for j in ["--", "..", "^^"]:
			res = res.replace(f", {j}, ", j)
		return res

	def emit(self):
		raise Exception("Operation not recognized")

	def post_emit(self):
		return None


class Blank(Op):
	def emit(self):
		return ""


class Point(Op):
	def __init__(self, name, exp, **options):
		self.name = name
		self.exp = exp
		self.dot = options.get("dot", True)
		self.label = options.get("label", name)
		if self.label:
			self.label = self.label.replace("_prime", "'")
		self.direction = options.get("direction", f"dir({name})")

	def emit(self):
		return f"pair {self.name} = {self.emit_exp()};"

	def post_emit(self):
		args = [self.name]
		if self.label:
			args = [f'"${self.label}$"', *args, self.direction]
		if self.dot:
			return f"dot({', '.join(args)});"
		if len(args) > 1:
			return f"label({', '.join(args)});"


class Draw(Op):
	def __init__(self, exp, **options):
		self.exp = exp
		self.fill = options.get("fill", None)
		self.outline = options.get("outline", None)

	def emit(self):
		exp = self.emit_exp()
		if self.fill:
			outline = self.outline or "defaultpen"
			return f"filldraw({exp}, {self.fill}, {outline});"
		elif self.outline:
			return f"draw({exp}, {self.outline});"
		else:
			return f"draw({exp});"


class Parser:
	def __init__(self, **args):
		self.soft_label = args.get("soft_label", False)
		self.alias_map = {"": "dl", ":": "", ".": "d", ";": "l"}
		if self.soft_label:
			self.alias_map |= {"": "l", ";": "dl"}
		self.aliases = self.alias_map.keys() | self.alias_map.values()

	def tokenize(self, line):
		line = line.strip() + " "
		for old, new in [
			# ~ and = are separate tokens
			("~", " ~ "),
			("=", " = "),
			# for tsqx syntax processing
			("(", "( "),
			(")", " ) "),
			(",", " , "),
			# spline joiners
			("--", " --  "),
			("..", " .. "),
			("^^", " ^^ "),
			# no spaces around asymptote arithmetic
			(" +", "+"),
			("+ ", "+"),
			("- ", "-"),
			(" *", "*"),
			("* ", "*"),
			# but slashes in draw ops should remain tokens
			(" / ", "  /  "),
			(" /", "/"),
			("/ ", "/"),
			# ' not allowed in variable names
			("'", "_prime"),
		]:
			line = line.replace(old, new)
		return list(filter(None, line.split()))

	def parse_subexp(self, tokens, idx, func_mode=False):
		token = tokens[idx]
		if token[-1] == "(":
			is_func = len(token) > 1
			res = []
			idx += 1
			if is_func:
				res.append(token[:-1])
			while tokens[idx] != ")":
				exp, idx = self.parse_subexp(tokens, idx, is_func)
				res.append(exp)
			return res, idx + 1
		if token == "," and func_mode:
			return "", idx + 1
		return token, idx + 1

	def parse_exp(self, tokens):
		if tokens[0][-1] != "(" or tokens[-1] != ")":
			tokens = ["(", *tokens, ")"]
		res = []
		idx = 0
		while idx != len(tokens):
			try:
				exp, idx = self.parse_subexp(tokens, idx)
				res.append(list(filter(None, exp)))
			except IndexError:
				raise SyntaxError("Unexpected end of line")
		return res

	def parse_special(self, tokens, comment):
		if not tokens:
			raise SyntaxError("Can't parse special command")
		head, *tail = tokens
		if comment:
			yield Blank(), comment
		if head in ["triangle", "regular"]:
			for name, exp in zip(tail, generate_points(head, len(tail))):
				yield Point(name, [exp]), None
			return
		else:
			raise SyntaxError("Special command not recognized")

	def parse_name(self, tokens):
		if not tokens:
			raise SyntaxError("Can't parse point name")
		name, *rest = tokens

		if rest and rest[-1] in self.aliases:
			*rest, opts = rest
		else:
			opts = ""
		opts = self.alias_map.get(opts, opts)
		options = {"dot": "d" in opts, "label": "l" in opts and name}

		if rest:
			dirs, *rest = rest
			if dir_pairs := re.findall(r"(\d+)([A-Z]+)", dirs):
				options["direction"] = "+".join(f"{n}*plain.{w}" for n, w in dir_pairs)
			elif dirs.isdigit():
				options["direction"] = f"dir({dirs})"
			elif re.fullmatch(r"N?S?E?W?", dirs):
				options["direction"] = f"plain.{dirs}"
			else:
				rest.append(dirs)
		if "direction" not in options:
			options["direction"] = f"dir({name})"

		if rest:
			raise SyntaxError("Can't parse point name")
		return name, options

	def parse_draw(self, tokens):
		try:
			idx = tokens.index("/")
			fill_ = tokens[:idx]
			outline = tokens[idx + 1:]
		except ValueError:
			fill_ = []
			outline = tokens

		fill = []
		for pen in fill_:
			if re.fullmatch(r"\d*\.?\d*", pen):
				fill.append(f"opacity({pen})")
			else:
				fill.append(pen)

		return {"fill": "+".join(fill), "outline": "+".join(outline)}

	def parse(self, line):
		line, *comment = line.split("#", 1)
		tokens = self.tokenize(line)
		if not tokens:
			yield (Blank(), comment)
			return
		# special
		if tokens[0] == "~":
			yield from self.parse_special(tokens[1:], comment)
			return
		# point
		try:
			idx = tokens.index("=")
			name, options = self.parse_name(tokens[:idx])
			exp = self.parse_exp(tokens[idx + 1:])
			yield Point(name, exp, **options), comment
			return
		except ValueError:
			pass
		# draw with options
		try:
			idx = tokens.index("/")
			exp = self.parse_exp(tokens[:idx])
			options = self.parse_draw(tokens[idx + 1:])
			yield Draw(exp, **options), comment
			return
		except ValueError:
			pass
		# draw without options
		exp = self.parse_exp(tokens)
		yield Draw(exp), comment
		return


class Emitter:
	def __init__(self, lines, print_=print, **args):
		self.lines = lines
		self.print = print_
		self.preamble = args.get("preamble", False)
		self.size = args.get("size", "8cm")
		self.parser = Parser(**args)

	def emit(self):
		if self.preamble:
			self.print("import olympiad;")
			self.print("import cse5;")
			self.print("size(%s);" % self.size)
			self.print("defaultpen(fontsize(9pt));")
			self.print('settings.outformat="pdf";')

		ops = [oc for line in self.lines for oc in self.parser.parse(line)]
		for op, comment in ops:
			out = op.emit()
			if comment:
				out = f"{out} //{comment[0]}".strip()
			self.print(out)
		self.print()
		for op, comment in ops:
			if out := op.post_emit():
				self.print(out)


def main():
	from argparse import ArgumentParser

	argparser = ArgumentParser(description="Generate Asymptote code.")
	argparser.add_argument(
		"-p",
		"--pre",
		help="Adds a preamble.",
		action="store_true",
		dest="preamble",
		default=False,
	)
	argparser.add_argument(
		"fname",
		help="Read from file rather than stdin.",
		metavar="filename",
		nargs="?",
		default="",
	)
	argparser.add_argument(
		"-s",
		"--size",
		help="Set image size in preamble.",
		action="store",
		dest="size",
		default="8cm",
	)
	argparser.add_argument(
		"-sl",
		"--soft-label",
		help="Don't draw dots on points by default.",
		action="store_true",
		dest="soft_label",
		default=False,
	)
	args = argparser.parse_args()
	stream = open(args.fname, "r") if args.fname else sys.stdin
	emitter = Emitter(stream, print, **vars(args))
	emitter.emit()


if __name__ == "__main__":
	main()
