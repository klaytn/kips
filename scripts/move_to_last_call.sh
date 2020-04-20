#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function printUsage {
  echo "Usage: $0 <KIP number>"
}

NUMBER=$1
if [ -z $NUMBER ]; then
  printUsage
  exit 1
fi

KIP_DOC_FILE="$DIR/../KIPs/kip-$NUMBER.md"
if [ ! -f $KIP_DOC_FILE ]; then
  echo "file does not exist: $KIP_DOC_FILE"
  printUsage
  exit 1
fi

# check if it is in status `Draft`
grep "status: Draft" $KIP_DOC_FILE
if [ $? -ne 0 ]; then
  echo "The specified KIP is not in the Draft status!"
  grep "status:" $KIP_DOC_FILE
  printUsage
  exit 1
fi


DATE=`date -v+14d +%Y-%m-%d`

perl -i -pe "BEGIN{undef $/;} s/status: Draft/status: Last Call\nreview-period-end: $DATE/sm" $KIP_DOC_FILE
