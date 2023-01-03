#!/bin/sh

# prep directory
mkdir -p ./sources
rm README.md
echo "# Pi-hole Blocklist" > README.md
echo "Aggregates Pi-Hole lists into a single list with automation. Please consider supporting the creators listed in \`sources.json\`." >> README.md
echo "|Source|" >> README.md; echo "|---|" >> README.md

# download source
for line in $(cat sources.json | jq -r '.sources[] | [.name,.url] | @csv')
do
  name="$(echo $line | cut -d "," -f 1 | tr -d '"')"
  url="$(echo $line | cut -d "," -f 2 | tr -d '"')"
  echo "Fetching $name" 
  curl $url -o ./sources/$name.txt --retry 9 --max-time 60 --retry-delay 60 --retry-max-time 180
  echo "|[$name]($url)|" >> README.md
done

cat ./sources/*.txt | sed 's/127.0.0.1 //g' | sed 's/0.0.0.0 //g' | grep -vE '#|127.0.0.1|localhost|::0|::1|::2|::3' | grep -P "(?=^.{4,253}$)(^(?:[a-zA-Z0-9](?:(?:[a-zA-Z0-9\-]){0,61}[a-zA-Z0-9])?\.)+([a-zA-Z]{2,}|xn--[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])$)" >> hosts.lst
cat hosts-* >> hosts.lst
LC_ALL=C sort -u hosts.lst && rm hosts-*
split -d -n l/4 hosts.lst hosts- && rm hosts.lst
