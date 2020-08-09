#! /bin/bash
cat 10-million-password-list-top-1000000.txt | while read -r line; do
  md5h=$(echo -n $line | md5sum)
  echo "Hash of $line: $md5h"
  printf "\nHash of $line: $md5h" >> md5-1m-pass-result.txt
done
