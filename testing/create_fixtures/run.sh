#!/usr/bin/env bash --login

rvm use 2.4.1
cd testing/create_fixtures
#bundle
#rake clean
#parallel_cucumber features/
ruby run.rb
rake clean
