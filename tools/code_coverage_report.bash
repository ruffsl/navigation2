#!/bin/bash

if [ ! -d build ]; then
  echo "Please run this script from the root of your workspace."
  echo "Expected directory hierarchy is:"
  echo "example_ws"
  echo " - build"
  echo " - - package_a"
  echo " - - package_b"
  exit 1
fi

set -e

LCOVDIR=lcov
PWD=`pwd`

COVERAGE_REPORT_VIEW="genhtml"

for opt in "$@" ; do
  case "$opt" in
    clean)
      rm -rf install build log $LCOVDIR
      exit 0
      ;;
    codecovio)
      COVERAGE_REPORT_VIEW=codecovio
      ;;
    genhtml)
      COVERAGE_REPORT_VIEW=genhtml
      ;;
    ci)
      COVERAGE_REPORT_VIEW=ci
      ;;
  esac
done

set -o xtrace

# Ignore certain packages:
# - messages, which are auto generated files
# - system tests, which are themselves all test artifacts
# - rviz plugins, which are not used for real navigation

# Generate initial zero-coverage data.
# This adds files that were otherwise not run to the report
colcon lcov-result --initial \
  --packages-ignore-regex \
    ".*_msgs" \
    ".*_tests" \
    ".*_rviz.*"

# Capture executed code data.
colcon lcov-result \
  --packages-ignore-regex \
    ".*_msgs" \
    ".*_tests" \
    ".*_rviz.*"

if [ $COVERAGE_REPORT_VIEW = codecovio ]; then
  curl -s https://codecov.io/bash > codecov
  codecov_version=$(grep -o 'VERSION=\"[0-9\.]*\"' codecov | cut -d'"' -f2)
  shasum -a 512 -c <(curl -s "https://raw.githubusercontent.com/codecov/codecov-bash/${codecov_version}/SHA512SUM" | grep -w "codecov")
  bash codecov \
    -f ${LCOVDIR}/total_coverage.info \
    -R src/navigation2
elif [ $COVERAGE_REPORT_VIEW = genhtml ]; then
  genhtml ${LCOVDIR}/total_coverage.info \
    --output-directory ${LCOVDIR}/html
fi
