#!/bin/bash

# Paste into command shell to search for duplicate texture names.
ls -R | sort | uniq -c | grep '\<[2-9][0-9]*[ ].*$'

# To find path of listed duplicates
find . -name <file name here>
