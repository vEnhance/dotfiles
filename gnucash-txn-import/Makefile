all: output/report.diff

/tmp/gnucash.xml: /home/evan/Sync/Grownup/Finance/gnucash/main.gnucash
	zcat $< > $@

output/pending.csv: /tmp/gnucash.xml scrape_xml.py txn.py
	python scrape-xml.py > $@

output/posted.csv: audit.py txn.py $(wildcard data*)
	python audit.py > $@

output/report.diff: output/posted.csv output/pending.csv
	diff $^ > $@ || :

data/auto-gen-techcu.csv: data/techcu.html
	./import-recent.sh
