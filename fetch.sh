#!/bin/sh

for line in $(cat sources.json | jq -r '.sources[] | [.name,.url] | @csv')
do
  name="$(echo $line | cut -d "," -f 1 | tr -d '"')"
  url="$(echo $line | cut -d "," -f 2 | tr -d '"')"
  echo "Fetching $name" 
  curl $url -o $name.txt
done

cat *.txt | grep -vE '#|127.0.0.1|localhost|::0|::1|::2|::3' | sed 's/\r$//;s/0.0.0.0 //g' | sort -u > hosts.lst
rm *.txt