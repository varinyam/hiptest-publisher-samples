#!/bin/bash
set -e

header() {
  local msg=$1
  echo "==============================================================================="
  echo $*
  pwd
  echo "==============================================================================="
}

logMessage() {
  echo "-------------------------------------------------------------------------------"
  echo "$*"
  echo "-------------------------------------------------------------------------------"
}

# gem install hiptest-publisher

cd ruby
header "Ruby"

logMessage "Installing"
bundle install

logMessage "Updating rspec tests"
hiptest-publisher -c rspec.conf --tests-only -v
logMessage "Running rspec tests"
bundle exec rspec -r rspec-extra-formatters -f TapFormatter > results_rspec.tap
hiptest-publisher -p results_rspec.tap -c rspec.conf

logMessage "Updating minitest tests"
hiptest-publisher -c minitest.conf --tests-only
logMessage "Running minitest tests"
bundle exec ruby -Ilib test/project_test.rb - --tapy | tapout tap > results_minitest.tap
hiptest-publisher -p results_minitest.tap -c minitest.conf
cd -

exit

cd python
header "Python"

logMessage "Installing"
python bootstrap.py
bin/buildout
logMessage "Updating tests"
hiptest-publisher -c unittest.conf --tests-only
logMessage "Running tests"
bin/test

cd -

cd java-junit
header "Java / JUnit"

logMessage "Updating tests"
hiptest-publisher -c junit.config --tests-only
logMessage "Packaging and running tests"
mvn package

cd -

cd java-testng
header "Java / TestNG"

logMessage "Updating tests"
hiptest-publisher -c testng.config --tests-only
logMessage "Packaging and running tests"
mvn package

cd -


cd robotframework
header "Robot framework"

logMessage "Installing"
sudo pip install robotframework

logMessage "Updating tests"
hiptest-publisher -c robotframework.conf --split-scenarios --test-only

logMessage "Running tests"
pybot -P src:tests tests/test_*

cd -

cd javascript
header "Javascript"

cd "selenium-ide"
logMessage "Updating Selenium IDE scripts"
hiptest-publisher -c seleniumide.conf
hiptest-publisher -c seleniumide.conf --split-scenarios
cd ..

cd ..