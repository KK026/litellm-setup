#!/bin/bash
ELB="a2f04f75604bf4f4986e350eaf4b6bcb-6b8ac33c01639c4c.elb.ap-south-1.amazonaws.com"
IP=$(nslookup $ELB | grep Address | tail -1 | awk '{print $2}')
echo "IP: $IP"
curl -s "https://freedns.afraid.org/dynamic/update.php?SmcyT0hzdDdENm9DWm5yY3BpUHJjZ1RSOjI2MTU4MTAx&address=$IP"
curl -s "https://freedns.afraid.org/dynamic/update.php?SmcyT0hzdDdENm9DWm5yY3BpUHJjZ1RSOjI2MTU4MTI0&address=$IP"
echo "Done!"
