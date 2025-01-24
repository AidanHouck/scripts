#!/usr/bin/env python3

# Connect to a list of hosts and do some basic cisco "show" commands

import warnings 
warnings.filterwarnings('ignore', '.*cryptography.*') # cryptography doesn't like python 3.5

import paramiko
import time
import sys
import os
import datetime
import re
import getpass

def get_user():
    return input('Username: ')

def get_pass():
    return getpass.getpass()

def get_en():
    return getpass.getpass(prompt='Enable: ')

def command(con, com):
    con.send(com)
    time.sleep(1)
    print('.', end='', flush = True)

def ssh_conn(ip, input_user, input_pass, input_enable):
    try:
        # Set up connection
        date_time = datetime.datetime.now().strftime("%Y-%m-%d")
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(ip, port=22, username=input_user, password=input_pass, look_for_keys=False, timeout=None)
        connection = ssh.invoke_shell()
        
        # check if we need to enable or not
        prompt = connection.recv(9999).decode(encoding='utf-8')
        search = re.search('(.+)>', prompt)
        connection.send("\n")
    
        if (search is not None):
            # Take last char (the prompt, usually '>' now)
            test_enable = search.group()[-1]
            if test_enable == '>':
                command(connection, "enable\n")
                command(connection, input_enable+"\n") 

        command(connection, "terminal length 0\n")
        connection.send("\n")
        
        # send show commands
        command(connection, "show version\n")
        command(connection, "show vlan\n")
        
        # Capture output
        data = connection.recv(256).decode(encoding='utf-8')
        hostname = (re.search('(.+)#', data)).group().strip('#')
        
        outFile = open("output/" + hostname + "_" + ip.strip('\n') + "_" + str(date_time) + ".txt", "w")

        outFile.writelines(data)

        while True:
            if connection.recv_ready():
                for data in connection.recv(4096).decode('utf-8'):
                    outFile.writelines(data)
            else:
                outFile.writelines("\n")
                break

        # Close connection
        outFile.close()
        ssh.close()
        print()
        print(hostname, " (", ip.strip("\n"), ") done", sep='')
        
    except paramiko.AuthenticationException:
        # Catch errors
        print("Error: Login failed. Username or password is incorrect.")

if __name__ == '__main__':
    # The format of the file below should just be plain text, 1 IP address per line
    print()
    try:
        iplist = open("iplist.txt")
    except:
        print("Error: iplist.txt file does not exist, please create it.")

    # Make `output/` dir if it doesn't exist already
    os.system("mkdir output 2>/dev/null")

    # get creds
    print('Enter login credentials for device(s)')
    input_user=get_user()
    input_pass=get_pass()
    input_enable=get_en()
    print()

    for line in iplist:
        print("Device ", line.strip("\n"), ":", sep='')
        ssh_conn(line, input_user, input_pass, input_enable)

    print()
    print("Execution finished, see `output/` directory for results")
    iplist.close()

