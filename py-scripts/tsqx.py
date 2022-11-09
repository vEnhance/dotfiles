#st#########
## TSQX ##
##########

# original TSQX by CJ Quines: https://github.com/cjquines/tsqx
# original TSQ by evan chen

from typing import Any, Generator
import re, sys


def generate_points(kind, n) -> list[str]:
	if kind == "triangle":
		return ["dir(110)", "dir(210)", "dir(330)"]
	elif kind == "regular":
		return [f"dir({(90 + i*360/n) % 360})" for i in range(n)]
	raise SyntaxError("Special command not recognized")


T_TOKEN = str | list[str] | list['T_TOKEN']


class Op:
	exp: T_TOKEN

	def _join_exp(self, exp: T_TOKEN, join_str: str) -> str:
		return join_str.join(self._emit_exp(e) for e in exp)

	def _emit_exp(self, exp: T_TOKEN) -> str:
		if not isinstance(exp, list):
			return exp
		if "," in exp:
			return f"({self._join_exp(exp, ' ')})"
		head, *tail = exp
		if not tail:
			if not isinstance(head, list):
				return head
			else:
				return self._emit_exp(head)
		if tail[0] in ["--", "..", "^^"]:
			return self._join_exp(exp, ", ")
		return f"{head}({self._join_exp(tail, ', ')})"

	def emit_exp(self) -> str:
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
	def __init__(
		self,
		name: str,
		exp: T_TOKEN,
		dot=True,
		label='',
		direction='',
	):
		self.name = name
		self.exp = exp
		self.dot = dot
		self.label = name if label else None
		if self.label:
			self.label = label.replace("_prime", "'")
		self.direction = direction or f"dir({name})"

	def emit(self) -> str:
		return f"pair {self.name} = {self.emit_exp()};"

	def post_emit(self):
		args = [self.name]
		if self.label:
			args = [f'"${self.label}$"', *args, self.direction]
		if self.dot:
			return f"dot({', '.join(args)});"
		if len(args) > 1:
			return f"label({', '.join(args)});"
		return ''


class Draw(Op):
	def __init__(
		self,
		exp: T_TOKEN,
		fill: str | None = None,
		outline: str | None = None,
	):
		self.exp = exp
		self.fill = fill
		self.outline = outline

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
	def __init__(self, soft_label: str | None = None, **_: Any):
		self.soft_label = soft_label
		self.alias_map = {"": "dl", ":": "", ".": "d", ";": "l"}
		if self.soft_label:
			self.alias_map |= {"": "l", ";": "dl"}
		self.aliases = self.alias_map.keys() | self.alias_map.values()

	def tokenize(self, line: str) -> list[T_TOKEN]:
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

	def parse_subexp(
		self,
		tokens: list[T_TOKEN],
		idx: int,
		func_mode=False,
	) -> tuple[T_TOKEN, int]:
		token = tokens[idx]
		if token[-1] == "(":
			is_func = len(token) > 1
			res: list[T_TOKEN] = []
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

	def parse_exp(self, tokens: list[T_TOKEN]):
		if tokens[0][-1] != "(" or tokens[-1] != ")":
			tokens = ["(", *tokens, ")"]
		res: list[T_TOKEN] = []
		idx = 0
		while idx != len(tokens):
			try:
				exp, idx = self.parse_subexp(tokens, idx)
				res.append(list(filter(None, exp)))
			except IndexError:
				raise SyntaxError("Unexpected end of line")
		return res

	def parse_special(self, tokens: list[T_TOKEN], comment: str | None):
		if not tokens:
			raise SyntaxError("Can't parse special command")
		head, *tail = tokens
		if comment is not None:
			yield Blank(), comment
		if head in ["triangle", "regular"]:
			for name, exp in zip(tail, generate_points(head, len(tail))):
				assert isinstance(name, str)
				yield Point(name, [exp]), None
			return
		else:
			raise SyntaxError("Special command not recognized")

	def parse_name(self, tokens: list[T_TOKEN]) -> tuple[str, dict[str, Any]]:
		if not tokens:
			raise SyntaxError("Can't parse point name")
		name, *rest = tokens
		assert isinstance(name, str)

		if rest and rest[-1] in self.aliases:
			*rest, opts = rest
			assert isinstance(opts, str)
		else:
			opts = ""
		opts = self.alias_map.get(opts, opts)
		options = {"dot": "d" in opts, "label": name if "l" in opts else None}

		if rest:
			dirs, *rest = rest
			assert isinstance(dirs, str)
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

	def parse_draw(self, tokens: list[T_TOKEN]):
		try:
			idx = tokens.index("/")
		except ValueError:
			fill_: list[T_TOKEN] = []
			outline_ = tokens
		else:
			fill_ = tokens[:idx]
			outline_ = tokens[idx + 1:]

		assert all(isinstance(_, str) for _ in outline_)
		outline: list[str] = [str(_) for _ in outline_]  # this is idiotic, what did i miss?

		fill: list[str] = []
		for pen in fill_:
			assert isinstance(pen, str)
			if re.fullmatch(r"\d*\.?\d*", pen):
				fill.append(f"opacity({pen})")
			else:
				fill.append(pen)

		return {"fill": "+".join(fill), "outline": "+".join(outline)}

	def parse(self, line: str) -> Generator[tuple[Draw | Blank | Point, str | None], None, None]:
		if '#' in line:
			line, comment = line.split("#", 1)
		else:
			comment = None
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
	def __init__(self, lines, print_=print, **args: Any):
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
			if comment is not None:
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
