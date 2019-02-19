#!/bin/bash

set -f

version=$(cat CHANGELOG.md | awk '
tolower($0) ~ /^ver.* / {
    print $2
    exit
}')

message=$(cat CHANGELOG.md | awk '
BEGIN {
    ORS = "\\n";
}
tolower($0) ~ /ver.* /,/NF/ {
    print $0
    if (NF==0) {
        exit
    }
}')

sed -i "/compile/s/[0-9]*\.[0-9]*\.[0-9]*/$version/" ./README.md

git config --global user.name "Travis"
git config --global user.email "app.nakayama@gmail.com"
git add ./README.md
git commit -m "bump version [ci skip]"
git tag -a $version -m "$message"
git push origin master
git push origin --tags
