#!/bin/bash

PROGNAME=`basename $0`
VERSAO="1.0"


banner(){
        echo -e " "
        echo " _____ ____  __  __    _____ _                 _ "
        echo "|_   _|  _ \|  \/  |  / ____| |               | |"
        echo "  | | | |_) | \  / | | |    | | ___  _   _  __| |"
        echo "  | | |  _ <| |\/| | | |    | |/ _ \| | | |/ _' |"
        echo " _| |_| |_) | |  | | | |____| | (_) | |_| | (_| |"
        echo "|_____|____/|_|  |_|  \_____|_|\___/ \__,_|\__,_|"
        echo "                                                 "
        echo -e " "
}

usage(){
banner
cat << !!
IBM Cloud - Permissionamento
versao ${VERSAO}
SYNTAX
        Uso: $PROGNAPROGNAME OPCAO
GENERAL SYNTAX
        Usage: ${PROGNAME} [-h]
OPTIONS
        -poc    Exibe apenas as informações referentes a contas PoC
		Usage: ${PROGNAME} -poc
        -h 	Exibe essa ajuda
!!
}

banner

if [ $1 == 'poc' ]
then
    for i in $(ibmcloud account list |  awk '{print $1}' | grep -v -e "Retrieving" -e "OK" -e "Account")
    do
	    ibmcloud target -c $i
        if [ $(ibmcloud account show --output 'JSON' | jq '.traits' | jq '.poc') == 'true' ]
        then
            ibmcloud account show 
            ibmcloud sl call-api SoftLayer_Account getAllRecurringTopLevelBillingItems  --mask 'mask[ id, description, hostName, domainName, recurringFee, createDate, categoryCode, category[name], location[name] ]' | jq -r '.[] | select(.recurringFee!= "0") | [.recurringFee, .categoryCode, .description, .hostName] | @csv' | awk -v FS="," 'BEGIN{print "Cost\tCategory\tDescription\thostName"}{printf "%s\t%s\t%20s\t%s%s", $1, $2, $3, $4, ORS}' | column -s $'\t' -t
            ibmcloud sl call-api SoftLayer_Account getNextInvoiceTotalAmount
        fi
    done
else
    if [ $1 == '-h' ]
    then
        usage
        exit
    else
        for i in $(ibmcloud account list |  awk '{print $1}' | grep -v -e "Retrieving" -e "OK" -e "Account")
        do 
            ibmcloud target -c $i
            ibmcloud account show 
            ibmcloud sl call-api SoftLayer_Account getAllRecurringTopLevelBillingItems  --mask 'mask[ id, description, hostName, domainName, recurringFee, createDate, categoryCode, category[name], location[name] ]' | jq -r '.[] | select(.recurringFee!= "0") | [.recurringFee, .categoryCode, .description, .hostName] | @csv' | awk -v FS="," 'BEGIN{print "Cost\tCategory\tDescription\thostName"}{printf "%s\t%s\t%20s\t%s%s", $1, $2, $3, $4, ORS}' | column -s $'\t' -t
            ibmcloud sl call-api SoftLayer_Account getNextInvoiceTotalAmount
        done
    fi
fi
