#!/bin/bash

# Load Balancer ka URL
ELB="ac5f1a46464e44c12b605347f9ffcc43-b67b86bb8bac16ae.elb.ap-south-1.amazonaws.com"

# IP nikalna
IP=$(nslookup $ELB | grep Address | tail -1 | awk '{print $2}')

echo "ELB ki IP aayi: $IP"
echo -n "DuckDNS Status: "

# DuckDNS Update
curl -s "https://www.duckdns.org/update?domains=kailashtech&token=cb8f7e7a-235d-4d1a-a01f-94ee997c4666&ip=$IP"
echo ""
