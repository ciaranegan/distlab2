#!/bin/sh

port_no=$1

# Default port 8000 if no port number passed to script
if [ -z "$port_no" ]
then
port_no=8000
fi

ruby pool_server.rb $port_no