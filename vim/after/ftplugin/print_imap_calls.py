calls = {
	'Thm': 'theorem',
	'Proof': 'proof',
	'Soln' : 'soln',
	'Solution' : 'solution',
	'Cor' : 'corollary',
	'Lemma' : 'lemma',
	'Prop' : 'proposition', 
	'Exer' : 'exercise',
	'Exercise' : 'exercise',
	'Example' : 'example',
	'Theorem' : 'theorem',
	'Def' : 'definition',
	'Fact' : 'fact',
	'Problem' : 'problem',
	'Remark' : 'remark',
	'Prob' : 'problem',
	'Claim' : 'claim',
	'Answer' : 'answer',
	'Hint' : 'hint',
	'Question' : 'ques',
	'Conj' : 'conjecture',
}

generic_string = r'''call IMAP('Upper::', "\\begin{env}\<CR><++>\<CR>\\end{env}<++>", 'tex')
call IMAP('Upper[]::', "\\begin{env}[<++>]\<CR><++>\<CR>\\end{env}<++>", 'tex')
call IMAP('lower::', "\\begin{env*}\<CR><++>\<CR>\\end{env*}<++>", 'tex')
call IMAP('lower[]::', "\\begin{env*}[<++>]\<CR><++>\<CR>\\end{env*}<++>", 'tex')'''
for key, val in calls.iteritems():
	final = generic_string
	final = final.replace('Upper', key)
	final = final.replace('lower', key.lower())
	final = final.replace('env', val)
	print final
