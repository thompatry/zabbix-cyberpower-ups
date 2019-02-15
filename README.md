# Zabbix CyberPower UPS template
# Tested on Zabbix 4.0.3

## Installation (Generic x86_64)
- Copy `cyberpower-ups_data.sh` to `/etc/zabbix/bin`: `sudo cp cyberpower-ups_data.sh /etc/zabbix/bin` (If the bin directory does not exist, create it `sudo mkdir /etc/zabbix/bin`)
- Make it executable: `sudo chmod a+x /etc/zabbix/bin/cyberpower-ups_data.sh`
- Install the systemd service and timer: `sudo cp cyberpower-ups_data.service /etc/systemd/system` and `sudo cp cyberpower-ups_data.timer /etc/systemd/system`
- Start and enable the timer: `systemctl enable --now cyberpower-ups_data.timer`
- Copy cyberpower-ups_data.conf into /etc/zabbix/zabbix-agentd.d: `sudo cp cyberpower-ups_data.conf /etc/zabbix/zabbix_agentd.d`
- Restart zabbix-agent: `sudo systemctl restart zabbix-agent`
- Import `template_cyberpower-ups_data.xml` on your Zabbix server
- Add template to server that has the pihole_data.sh service on in Zabbix