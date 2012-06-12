#!/bin/bash 

find . -type f | xargs perl -pi -e 's/$1/$2/g'
