---
title: Side Project: Count Words Notification with Git Diff
category: Side-Project
tags: [Git, Bash, Side]
---

# Side Project: Count Words Notification with Git Diff

My daily goal is to write 1,000 words, then I feel productive at the end of the day.
There are, of course, exceptions; writing theoretical-based (math) papers or programming days are more exhausting than typical everyday work.
And the number of words does not tell anything about quality, but still, it's a considerable metric. (If you've typed zero words in a day, you also did not write anything outstanding)

I've programmed a bash script that counts words in Latex files from given Git repositories.
It therefore counts the number of changed words with Git-diff and displays it in a push notification on my mobile phone.
The script is automatically called by a Cronjob at 17:00 (5pm) from Mon-Fri.
For the push notification I use [Pushover] which offers a HTTPS API.

## Bash Script
You can find the full bash script [here](/static/2021-01-29-count_words.sh). I know, *zsh* is the new ✨ thing. But I didn't have time to get into it, yet. I'm sure my git-diff is compatible ;-)

The script has a hardcoded list of relative paths to Git repositories to scan.
It loops trough them and executes *git diff* with some parameters:

- ```--word-diff=porcelain``` enables a high-level diff 
which is actually not supposed to be parsed
but outputs all diff words as we need them for counting
- ```@{yesterday}..@{now}``` look for changes back until yesterday

Then filter the diff results:
- ```grep "^[+-]"``` filter for changes (+ for new line, - for deleted line)
- ```sed s/^[+-]//``` remove the +- prefix (the "porcelain" shouldn't be counted)
- ```grep -E "[a-zA-Z]+"``` filter for words that consists out of letters (can be improved)
- ```grep -E -v "\\\\[a-zA-Z0-9]*[*]?{?``` ignore words that are actually LaTeX commands, e.g., ```\begin``` (can be improved, too)
- ```grep -E -v "^[\\b]*%"``` ignore comment lines
- ```grep -E -v "^[+-]{2}``` ignore empty +- lines

Finally, count the words:
- ```wc -w```

> These filters can be improved a lot! But right now, they are useful enough (for me).

## Pushover
The word count loop generates a nicely formatted string and sends it via [Pushover] to my devices:

```sh
APP_TOKEN="APP_TOKEN_1337"
USER_KEY="#CAFFEEAFFE"

curl -s \
  --form-string "token=$APP_TOKEN" \
  --form-string "user=$USER_KEY" \
  --form-string "title=$TITLE" \
  --form-string "message=$MESSAGE" \
  https://api.pushover.net/1/messages.json > /dev/null 2>&1 &
```

## Cronjob
Add to user's Crontab:

```sh
crontab -e
```

Every Monday - Friday at 17:00 (5pm):

```
0 17 * * 1-5 /Users/rob/git/count-words/count_words.sh >/dev/null 2>&1
```

## Motivation!!!
![iPhone Notification](/static/2021-01-29-count_words-notification.jpg)


## Disclaimer
The script is written for counting English words. The ```[a-zA-Z]+``` word filter interferes with other languages. Maybe consider a better filter (or ```[\w]+```) for other languages.

[Pushover]: https://pushover.net
[here]: PATH

[//]: # ( #Sideprojects #Blog ) 
