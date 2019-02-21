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

git clone "git@github.com:$TRAVIS_REPO_SLUG.git"
cd git-test
sed -i "/compile/s/[0-9]*\.[0-9]*\.[0-9]*/$version/" ./README.md
git add ./README.md
git commit -m "bump version [ci skip]"
git push origin master

body=$(cat << EOF
{
  "tag_name": "$version",
  "target_commitish": "master",
  "name": "v$version",
  "body": "$(echo -e $msg)",
  "draft": false,
  "prerelease": false
}
EOF
curl -X POST -d $body -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$TRAVIS_REPO_SLUG/releases" \
    > /dev/null 2>&1
