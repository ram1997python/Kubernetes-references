#!/bin/bash
# Master Node Setup
sudo hostnamectl set-hostname worker2
echo "10.0.1.10 lb.kube.com lb" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.11 master1.kube.com master1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.12 master2.kube.com master2" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.13 worker1.kube.com worker1" | sudo tee -a /etc/hosts > /dev/null
echo "10.0.1.14 worker2.kube.com worker2" | sudo tee -a /etc/hosts > /dev/null