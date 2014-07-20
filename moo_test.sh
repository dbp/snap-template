#!/bin/bash

DBM_DATABASE="dbname='pcori_test' user='pcori_user' password='111'" DBM_DATABASE_TYPE="postgresql" DBM_MIGRATION_STORE="migrations" moo $@
