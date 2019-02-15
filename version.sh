#!/bin/bash

set -f

version=$(cat CHANGELOG.md | awk '
tolower($0) ~ /^ver.* / {
    print $2
    exit
}')
echo $version

msg=$(cat CHANGELOG.md | awk '
BEGIN {
    ORS = "\\n";
}
tolower($0) ~ /ver.* /,/NF/ {
    print $0
    if (NF==0) {
        exit
    }
}')
echo -e $msg
