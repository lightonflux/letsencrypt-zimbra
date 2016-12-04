#!/bin/bash
config_name="letsencrypt-zimbra.cfg"
systemd_unit_path="/etc/systemd/system/"
# check if user runs with root rights

if [ "$EUID" -ne 0 ]
    then echo "Please run this script with root rights"
    exit
fi

# check path of le-zimbra install
letsencrypt_zimbra_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# echo ${letsencrypt_zimbra_dir}

# check if user created config else exit

if [ -f "${letsencrypt_zimbra_dir}/${config_name}" ]
then
    echo -e "\e[92m✓\e[39m ${config_name} is present."
else
    echo -e "\e[91m✗\e[39m ${config_name} was not found.\e[49m"
    echo "Please create it."
    echo "You can use ${config_name}.example as a template."
    exit
fi

# check if systemd folder exits
if [ -d "${systemd_unit_path}" ]
then
    echo -e "\e[92m✓\e[39m ${systemd_unit_path} exists."
else
    echo -e "\e[91m✗\e[39m ${systemd_unit_path} not found."
    echo "Does your system use systemd?"
    exit
fi


cat << EOF > ${systemd_unit_path}/letsencrypt-zimbra.service
[Unit]
Description="Obtain and deploy Letsencrypt certs for Zimbra"

[Service]
Type=oneshot
ExecStart=${letsencrypt_zimbra_dir}/obtain-and-deploy-letsencrypt-cert.sh
EOF

cat << EOF > ${systemd_unit_path}/letsencrypt-zimbra.timer
[Unit]
Description="Timer for Letzencrypt Zimbra script"

[Timer]
OnCalendar=*-*-1 3:00

[Install]
WantedBy=basic.target
EOF

# Reading config files and enabling unit
systemctl daemon-reload
systemctl enable letsencrypt-zimbra.timer
systemctl start letsencrypt-zimbra.timer

echo -e "\e[92m✓\e[39m Timer and service unit were written to ${systemd_unit_path}."
echo ""
echo "You can check the timer with the following command:"
echo "    systemctl list-timers"
echo "And disable with"
echo "    systemctl disable --now letsencrypt-zimbra.timer"


