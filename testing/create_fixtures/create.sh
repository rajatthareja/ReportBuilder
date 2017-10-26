#!/usr/bin/env bash --login

cd testing/create_fixtures

rvm use 2.4.1
#bundle
#parallel_cucumber features/
ruby create.rb

rvm use 1.9.3
ruby create_r1.rb

rake clean
