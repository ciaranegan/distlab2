#!/bin/sh

port_no=$1

# Default port 8000 if no port number passed to script
if [ -z "$port_no" ]
then
port_no=8000
echo "Default port 8000 chosen"
fi

echo "$port_no"