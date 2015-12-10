import sys,os
import time

#Background colors {{{1
HEADER = '\033[95m'
OKBLUE = '\033[94m'
OKGREEN = '\033[92m'
WARNING = '\033[93m'
FAIL = '\033[91m'
BOLD = '\033[1m'
ENDC = '\033[0m'
# }}}
#Timed OS {{{1
def timedOS(s):
	start = time.time()
	signal = os.system(s)
	end = time.time()
	elapsed = end - start
	return (signal, elapsed)
#}}}
# Return first n lines {{{1
def abridge_file(filename, n=1):
	f = open(filename, "r")
	lines = f.readlines()
	f.close()
	if (len(lines) <= n):
		return ''.join(lines)
	else:
		return ''.join(lines[:n]) + "... and more ...\n"
# }}}
# Print standard output, if any. {{{1
def printStdOut(): 
	try:
		debug_log_lines = open("debug.log", "r").readlines()
		if len(debug_log_lines) == 0: pass
		else:
			print HEADER + "Here is standard output: " + ENDC
			print abridge_file("debug.log",5)
	except IOError:
		return
#}}}

file_type = ""
class_name = sys.argv[1].strip()
if class_name.find('.') != -1: class_name = class_name[0:class_name.find('.')]

#Compile {{{1
if os.path.isfile(".build"):
	file_type = "auto"
	build_file = open(".build", "r")
	if os.system(build_file.readline().strip()) != 0: exit()
	cmd = build_file.readline().strip()
	build_file.close()
elif os.path.isfile(class_name + ".cpp"):
	file_type = "cpp"
	if os.system("g++ %s.cpp" %class_name) != 0: exit()
	cmd = "./a.out"
elif os.path.isfile(class_name + ".java"):
	file_type="java"
	if os.system("javac %s.java" %class_name) != 0: exit()
	cmd = "java -ea %s" %class_name
elif os.path.isfile(class_name + ".py"):
	file_type="py"
	cmd = "python %s.py" %class_name
else:
	print "Not supported."
	exit()
# }}}
#Move in file somewhere safe {{{1
if os.path.exists("%s.in" %class_name):
	os.system("mv %s.in %s.in_old" %(class_name, class_name))
# }}}

test_case = 1
all_ok = True
while os.path.exists('test/%d.in' %test_case) or os.path.exists('test/%d.py' %test_case):
	if os.path.exists('test/%d.in' %test_case):
		os.system('cat test/%d.in > %s.in' %(test_case, class_name))
	else:
		os.system('python test/%d.py > %s.in' %(test_case, class_name))
	signal, elapsed = timedOS('cat %s.in | %s > debug.log' %(class_name, cmd))
	# If there is no output file, use standard output
	if not os.path.exists("%s.out" %class_name):
		os.system("mv debug.log %s.out" %class_name)
		need_del_out = True
	else:
		need_del_out = False
	#Check if error {{{1
	if signal != 0:
		print WARNING + "* SIGNAL %d on test case %d. *" %(signal, test_case) + ENDC
		printStdOut()
		all_ok = False
		break
	#}}}
	#Check if correct output {{{1
	if os.system("diff %s.out test/%d.out > /dev/null" %(class_name, test_case)):
		print WARNING + "* BADCHECK on test case %d. *" %(test_case) + ENDC
		printStdOut()
		print WARNING + "Correct Answer:" + ENDC
		print ENDC + abridge_file("test/%d.out" %(test_case), 3) + ENDC
		print WARNING + "User Answer:" + ENDC
		print ENDC + abridge_file("%s.out" %(class_name), 3) + ENDC
		all_ok = False
		break
	#}}}
	# Print OK and such {{{1
	if elapsed < 1:
		print "Test %d: %sTEST OK%s [%.3f secs]" %(test_case, OKBLUE, ENDC, elapsed)
	else:
		print "Test %d: %sTEST OK%s %s[%.3f secs]%s" %(test_case, OKBLUE, ENDC, WARNING, elapsed, ENDC)

	if os.path.isfile("debug.log"): os.system('rm debug.log')
	test_case += 1
	# }}}

	if need_del_out:
		os.system("rm %s.out" %class_name)

if need_del_out:
	os.system("rm %s.out" %class_name)

# Congratulate/yell at user. {{{1
if test_case == 1 and all_ok:
	print WARNING + BOLD + "No test cases found!" + ENDC
elif all_ok: 
	print OKBLUE + BOLD + "* All tests OK. *" + ENDC
	os.system("mv %s.in_old %s.in" %(class_name, class_name))
else: 
	print FAIL + BOLD + "* CASE %d FAILED *" %(test_case) + ENDC
# }}}

# vim:foldmethod=marker
