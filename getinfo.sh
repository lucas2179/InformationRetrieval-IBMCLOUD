#!/bin/bash

ibmcloud login --sso

for i in $(ibmcloud account list |  awk '{print $1}' | grep -v -e "Retrieving" -e "OK" -e "Account")
do
    ibmcloud target -c $i
    ibmcloud account show 
    idrec = ibmcloud sl call-api SoftLayer_Account getLatestRecurringInvoice | jq '.id'
    ibmcloud sl call-api SoftLayer_Billing_Invoice getInvoiceTopLevelItems --init $idrec --mask 'mask[ id, description, hostName, domainName, oneTimeAfterTaxAmount, recurringAfterTaxAmount, createDate, categoryCode, category[name], location[name] ]' | jq -r '.[] | [.recurringAfterTaxAmount, .categoryCode, .description, .hostName] | @csv' | awk -v FS="," 'BEGIN{print "Cost\tCategory\tDescription\thostName"}{printf "%s\t%s\t%20s\t%s%s", $1, $2, $3, $4, ORS}' | column -s $'\t' -t
done
