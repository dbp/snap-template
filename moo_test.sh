#!/bin/bash

DBM_DATABASE="dbname='db_test' user='db_user' password='111'" DBM_DATABASE_TYPE="postgresql" DBM_MIGRATION_STORE="migrations" moo $@
