#/bin/bash
for ((i=0; i<=100000000; i++))
do
	md5h=$(echo -n $i | md5sum)
  echo "Hash of $i: $md5h"
	printf "\nHash of $i: $md5h" >> md5-1m-num-result.txt
done
