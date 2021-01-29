#!/bin/bash

# Config git repos here (relative to ../)
DIRECTORIES=( "promotion" "bbb-paper" "security-analysis" "top-transparent-paper" )

# Pushover credentials
APP_TOKEN="1337"
USER_KEY="#CAFFEEAFFE"

###############

SUM=0 # sum of all repo 
MESSAGE="" # notification body

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" # directory of bash script

for dir in "${DIRECTORIES[@]}" ; do
	cd $DIR/../$dir
	words=$(git diff --word-diff=porcelain @{yesterday}..@{now} | grep "^[+-]" | sed s/^[+-]// | grep -E "[a-zA-Z]+" | grep -E -v "\\\\[a-zA-Z0-9]*[*]?{?" | grep -E -v "^[\\b]*%" | grep -E -v "^[+-]{2}" | wc -w)
	words=$(echo $words | sed 's/[^0-9]//g')

	SUM=$(($SUM + $words))
	if [ -n "$MESSAGE" ] ; then
		MESSAGE="$MESSAGE, "
	fi

	MESSAGE="$MESSAGE$dir: $words"
done

# show diff message
echo -e "$MESSAGE"
echo "sum: $SUM"

# Submit to pushover.net
TITLE="Words today: $SUM"

curl -s \
  --form-string "token=$APP_TOKEN" \
  --form-string "user=$USER_KEY" \
  --form-string "title=$TITLE" \
  --form-string "message=$MESSAGE" \
  https://api.pushover.net/1/messages.json > /dev/null 2>&1 &

