#!/bin/bash

REPO_PATH="${PROJECT_HOME}/cwcloud-wordpress-email"

cd "${REPO_PATH}" && git pull origin main || :
git push github main 
git push pgitlab main
exit 0
