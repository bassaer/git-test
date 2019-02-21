#!/bin/bash

set -ef

if [ "$TRAVIS_PULL_REQUEST" != "false" ]; then
    echo "pull request build."
    exit 0
fi

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

openssl aes-256-cbc -K $encrypted_5ef410394863_key -iv $encrypted_5ef410394863_iv -in travis_rsa.enc -out ~/.ssh/id_rsa -d
chmod 600 ~/.ssh/id_rsa
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

git config --global user.name "TravisCI"
git config --global user.email "app.nakayama@gmail.com"

git clone git@github.com:bassaer/git-test.git
cd git-test
sed -i "/compile/s/[0-9]*\.[0-9]*\.[0-9]*/$version/" ./README.md
git add ./README.md
git commit -m "bump version [ci skip]"
git tag -a $version -m $(echo -e $msg)
git push origin master
git push origin --tags
