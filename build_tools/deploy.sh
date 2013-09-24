#!/bin/bash

echo "creating brach and deploying to watchdog-hache2i-heroku"
git checkout -b local_temp
git add .
git commit -m "local changes not going to production"
git checkout master
git pull origin master
git checkout -b deploy
git push -f heroku deploy:master
git reset --hard
git checkout master
git merge local_temp
git branch -D local_temp
git branch -D deploy
