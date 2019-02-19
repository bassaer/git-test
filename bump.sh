#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" -ne "false" ]; then
    echo "pull request build."
    exit 0
fi

set -f

version=$(cat CHANGELOG.md | awk '
tolower($0) ~ /^ver.* / {
    print $2
    exit
}')

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

sed -i "/compile/s/[0-9]*\.[0-9]*\.[0-9]*/$VERSION/" ./README.md

openssl aes-256-cbc -K $encrypted_5ef410394863_key -iv $encrypted_5ef410394863_iv -in travis_rsa.enc -out ~/.ssh/travis_rsa -d
chmod 600 ~/.ssh/id_rsa
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

git config --global user.name "TravisCI"
git config --global user.email "app.nakayama@gmail.com"
git add ./README.md
git commit -m "update version [ci skip]"
git tag -a $version -m "$msg"
git push origin master
git push origin --tags

echo "$version : $msg"
