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

# check if it is in status `Last Call`
grep -A1 "status: Last Call$" $KIP_DOC_FILE | grep "review-period-end: "
if [ $? -ne 0 ]; then
  echo "The specified KIP is not in the Last Call status!"
  grep "status:" $KIP_DOC_FILE
  printUsage
  exit 1
fi

perl -i -pe 'BEGIN{undef $/;} s/status: Last Call\nreview-period-end: [0-9]{4}-[0-9]{2}-[0-9]{2}$/status: Final/sm' $KIP_DOC_FILE

