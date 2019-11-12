#!/bin/bash

for node in $(kubectl get nodes | grep -v NAME | awk '{ print $1 }')
do
  kubectl label node $node failure-domain.beta.kubernetes.io/zone=ams --overwrite
done
