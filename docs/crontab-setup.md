Reference: https://www.howtogeek.com/746532/how-to-launch-cron-automatically-in-wsl-on-windows-10-and-11/

0. Ensure CRON is running. See reference to automate on WSL which does not start cron by default.
```bash
sudo service cron status
sudo service cron start
```

1. Add new cronjob
```bash
crontab -e
# -u used to set the user crontab runs as. By default, the user
# executing the command. This gets confusing with `su` so always
# specify user for sanity when using `su`. Should be ok for
# standard usage though without

# alternatively add files in /etc/cron.d for organization, but
# note that this differs by distros
sudo touch /etc/cron.d/my-cool-cronjob
```

2. Add line
```bash
# Line is in the format of:
# M H D M W command
# For help with formatting date options, see:
# https://crontab.guru/
*/10 * * * * <user> /etc/cron.d/my-cool-script.sh

# <user> is REQUIRED for /etc/cron.d/bla cronjobs, and not
# for `crontab -e` cronjobs.
```

3. Verify crontab schedule & command look as desired
```bash
crontab -l
# OR
cat /etc/cron.d/my-cool-cronjob
```

