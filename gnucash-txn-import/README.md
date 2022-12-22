# Balance checkbook automation

## Import instructions

### Download Tech CU (for importing)

Go to Accounts, then use "Print" and save resulting HTML (HTML only, not webpage
complete). Save only a single file `data/techcu.html` since it combines both
savings and checking.

### Download Citi (for importing)

Click the stupid Export icon,
choose "year to date", then export as CSV to `data/citi.csv`.

### Run

Ensure GnuCash is closed and run `import-recent.sh`.

## Diff-ing

Only if you are having trouble getting something to balance

### Download BoA

Under the "Download" button, grab the most recent transactions and export
as printable text format

### Download PayPal

Use the URL https://business.paypal.com/merchantdata/consumerHome
and download a CSV.

### Run make

make
