#!/bin/bash

echo "Setting up the project... [NOTE: THIS WILL ONLY WORK ONCE. RE-CLONE TO REDO]"

read -e -p "Enter an all-lowercase version of the project name (ex: 'albatross'): " proj_name
read -e -p "Enter the deploying user on the production server: " remote_user
read -e -p "Enter the domain for production (no www): " prod_domain
read -e -p "Enter the author name for the project: " author_name
read -e -p "Enter the author email for the project: " author_email
read -e -p "Enter the email address that messages from the site will come from: " site_email
read -e -p "Enter the license for the project (ex: GPL, BSD3, AllRightsReserved): " -i "AllRightsReserved" license
read -e -p "Enter the password for development database (need not be secure): " db_pass

echo "Setting up..."

find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/PROJECT_NAME/${proj_name}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/REMOTE_USER/${remote_user}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/PRODUCTION_DOMAIN/${prod_domain}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/AUTHOR_NAME/${author_name}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/AUTHOR_EMAIL/${author_email}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/SITE_EMAIL/${site_email}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/LICENSE_NAME/${license}/g"
find . ! -iname configure.sh -type f -print0 | xargs -0 sed -i "s/DEVELOPMENT_PASSWORD/${db_pass}/g"
mv PROJECT_NAME.cabal ${proj_name}.cabal

echo "All done!"
