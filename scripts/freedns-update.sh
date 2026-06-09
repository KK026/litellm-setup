#!/bin/bash
ELB="YOUR_INGRESS_ELB_URL_HERE"
IP=$(nslookup $ELB | grep Address | tail -1 | awk '{print $2}')
echo "IP: $IP"
curl -s "LITELLM_FREEDNS_URL_HERE&address=$IP"
curl -s "GRAFANA_FREEDNS_URL_HERE&address=$IP"
echo "Done!"
