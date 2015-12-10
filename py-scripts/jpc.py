import sys,os
import time

def timedOS(s):
	add_args = ''.join([" \"%s\"" %blah for blah in sys.argv[2:]])
	start = time.time()
	signal = os.system(s + add_args)
	end = time.time()
	return (signal, end-start)

class_name = sys.argv[1].strip()
if class_name.find('.') != -1: class_name = class_name[0:class_name.find('.')]

if os.path.isfile(".build"):
	print "This is jpc, parsing %s" %class_name
	build_file = open(".build", "r")
	if os.system(build_file.readline().strip()) != 0: exit()
	signal, elapsed = timedOS(build_file.readline().strip())
	build_file.close()
elif os.path.isfile(class_name + ".cpp"):
	print "This is cow, parsing %s.cpp" %class_name
	if os.system("g++ %s.cpp" %class_name) != 0: exit()
	if os.path.isfile("%s.in" %class_name):
		signal, elapsed = timedOS("cat %s.in | ./a.out" %(class_name))
	else:
		signal, elapsed = timedOS("./a.out")
	if signal != 0:
		print "ERROR: Signal %s" %signal
		exit()
elif os.path.isfile(class_name + ".java"):
	print "This is jerm, parsing %s.java" %class_name
	if os.system("javac %s.java" %class_name) != 0: exit()
	if os.path.isfile("%s.in" %class_name):
		signal, elapsed = timedOS("cat %s.in | java -ea %s" %(class_name, class_name))
	else:
		signal, elapsed = timedOS("java -ea %s" % (class_name))
	if signal != 0: exit()
elif os.path.isfile(class_name + ".py"):
	print "This is piglet, parsing %s.py" %class_name
	if os.path.isfile("%s.in" %class_name):
		signal, elapsed = timedOS("cat %s.in | python %s.py" %(class_name, class_name))
	else:
		signal, elapsed = timedOS("python %s.py" %class_name)
	if signal != 0: exit()
else:
	print "Not supported."
	exit()

try:
	f = open("%s.out" %class_name, 'r')
	for line in f: print line.strip()
	f.close()
except IOError as e:
	pass

print "Execution time: %.3f secs" %(elapsed)
