#!/usr/bin/env bash

# get the system uname
UNAME=$(uname)
#UNAME="Darwin"

# ignore bc we are testing for TRAVIS below not TESTING
# comment this line out if we are not testing
# TESTING=1

# check python before setup
( command -v pip && pip --version ) || ( echo "ERROR: pip is not installed." ; exit 1 )
( command -v python && python --version ) || ( echo "ERROR: python is not installed." ; exit 1 )

# set pip and pipenv commands for to prevent actual setup when not on travis
if [[ -n "$TRAVIS" ]]; then
    PIP=pip
    PIPENV=pipenv
else
    PIP="$(command -v echo) fake pip"
    PIPENV="$(command -v echo) fake pipenv"
fi

# osx install pipenv with brew
if [[ "$TRAVIS_OS_NAME" == "osx" ]] || [[ "$UNAME" == "Darwin" ]]; then
    echo "begin $UNAME install ..."
    BREW=$(command -v brew)
    if [[ -z "$BREW" ]]; then
        BREW="$(command -v echo) fake brew"
    fi
    $BREW update
    $BREW install pipenv
# linux install pipenv with pip, but only from within a virtualenv
# travis puts your python in a virtualenv by default
elif [[ "$TRAVIS_OS_NAME" == "linux" ]] || [[ "$UNAME" == "Linux" ]]; then
    echo "begin $UNAME install ..."
    if [[ -z "$VIRTUAL_ENV" ]]; then
        echo "ERROR: installing pipenv outside of a virtualenv not supported."
        exit 1
    fi
    $PIP install pipenv --upgrade
else
    echo "ERROR: $UNAME install not supported."
    exit 1
fi

#check python after setup
pipenv run pip --version
pipenv run python --version

# install from Pipfile.lock
#$PIPENV install --dev --skip-lock
$PIPENV install --dev
