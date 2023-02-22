# Balance checkbook automation

## Import instructions

### Download Tech CU (for importing)

Go to Accounts, click either account, then use "Print" and save resulting HTML
(HTML only, not webpage complete). Save only a single file `data/techcu.html`
since it combines both savings and checking.

### Download Citi (for importing)

Go to the account, choose "year to date",
click the stupid Export icon (looks like "download")
then export as CSV to `data/citi.csv`.

### Download PayPal (for importing)

From the dashboard, press "Show All" or whatever
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
