# Balance checkbook automation

## Import instructions

### Download Tech CU (for importing)

Go to Accounts, then use "Print" and save resulting HTML (HTML only, not webpage
complete). Save only a single file `data/techcu.html` since it combines both
savings and checking.

### Download Citi (for importing)

Click the stupid Export icon,
choose "year to date", then export as CSV to `data/citi.csv`.

### Download PayPal (for importing)

From the dashboard, press "View All" or whatever
to get a list of recent transactions.
Grab the HTML element from the DOM and save it as `data/paypal.html`.

### Run

Ensure GnuCash is closed and run `import-recent.sh`.

---

## Diff-ing

Only if you are having trouble getting something to balance

### Download PayPal (for importing)

Use the URL https://business.paypal.com/merchantdata/consumerHome
and download a CSV. Save as `data/paypal.csv`.

### Download BoA

Under the "Download" button, grab the most recent transactions and export
as printable text format

### Run make

make
