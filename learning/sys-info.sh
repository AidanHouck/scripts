#!/usr/bin/env bash

# Show some basic machine information

# Hostname info
echo "----- Hostname Info -----"
hostnamectl
echo

# Filesystem info
echo "----- Filesystem Info -----"
df -h
echo

# Memory info
echo "----- Memory Info -----"
free -h
echo

# Logged-in users
echo "----- Logged-in users -----"
who
echo

