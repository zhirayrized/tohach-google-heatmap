#!/bin/bash
bundle install && bundle exec rake db:create db:migrate
echo "Please execute ./run.sh then upload your first geopoints set"
