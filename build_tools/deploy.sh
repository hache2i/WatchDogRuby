#!/bin/bash

echo "creating brach and deploying to watchdog-hache2i-heroku"
git checkout master
git pull origin master
git branch -D deploy
git checkout -b deploy
git push -f heroku deploy:master
git reset --hard
git checkout master
git branch -D deploy
