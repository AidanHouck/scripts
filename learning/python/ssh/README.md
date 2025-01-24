# SSH.py

Connects to a bunch of things over ssh and runs commands

### Install:
1. `python3 -m venv ssh-env` This will create the `ssh-env/` directory
2. `source ssh-env/bin/activate` 
3. `cd ssh-env/`
4. Place `ssh.py` and `requirements.txt` inside of `ssh-env/`
5. `python -m pip install -r requirements.txt`
6. `deactivate`

### Usage: 

1. `source ssh-env/bin/activate`
2. `cd ssh-env/`
3. Make sure `iplist.txt` has the correct IP addresses
4. Make sure the list of commands in `ssh_conn()`'s `# send show commands` section is what you want
5. `./ssh.py`
6. When prompted, enter the same username, password, and enable password that will be used for all switches
7. See output as `output/hostname-ipaddress-date.txt`
8. To return to normal python env, `deactivate`

This doesn't need to be used for only show commands but be very careful doing anything else with it

