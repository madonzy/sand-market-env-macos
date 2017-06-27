#!/bin/bash

ssh_port=$(docker port sand_market_box_web 22)
ssh_port=${ssh_port#*:}

ssh -N -p $ssh_port -R 9000:localhost:9000 magento2@127.0.0.1