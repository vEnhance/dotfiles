#!/bin/bash

python ~/dotfiles/gnucash-txn-import/scrape_citi.py
echo "----------------------------------------------"
python ~/dotfiles/gnucash-txn-import/scrape_techcu.py
echo "----------------------------------------------"
python ~/dotfiles/gnucash-txn-import/scrape_paypal.py
echo "----------------------------------------------"
python ~/dotfiles/gnucash-txn-import/scrape_boa.py
