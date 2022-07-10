#!/bin/sh

mkdir -p ./sources
for line in $(cat sources.json | jq -r '.sources[] | [.name,.url] | @csv')
do
  name="$(echo $line | cut -d "," -f 1 | tr -d '"')"
  url="$(echo $line | cut -d "," -f 2 | tr -d '"')"
  echo "Fetching $name" 
  curl $url -o ./sources/$name.txt --retry 5 --max-time 30 --retry-delay 60 --retry-max-time 180
done

cat *.txt | grep -vE '#|127.0.0.1|localhost|::0|::1|::2|::3' | sed 's/\r$//;s/0.0.0.0 //g' | sort -u > ./sources/hosts.lst
