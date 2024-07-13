#!/bin/bash

set -e

rm -rf makelove-build
makelove lovejs
unzip -o "makelove-build/lovejs/zero-days-and-nights-lovejs" -d makelove-build/html/
echo "http://localhost:8000/makelove-build/html/zero-days-and-nights/"
python3 -m http.server
# ruby -run -e httpd . -p 8000