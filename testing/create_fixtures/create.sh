#!/usr/bin/env bash --login

rvm use 2.4.1
cd testing/create_fixtures

#bundle
#parallel_cucumber features/

#ruby create_sample_report.rb

ruby create.rb

rvm use 1.9.3
ruby create_r1.rb

rake clean
