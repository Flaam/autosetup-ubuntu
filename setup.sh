## Colors
NC="\033[0m"
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[31m"

## Welcome message
echo -e "${GREEN}"
echo -e "--------------------------------------------------------"
echo -e "Welcome to Flaam's Ubuntu's automatic setup script"
echo -e "Script's source code is available at https://fla.am/ub"
echo -e "--------------------------------------------------------"
echo -e "⭐ Bloatware / unnecessary packages removal"
echo -e "⭐ Automatic updates and upgrades"
echo -e "⭐ Basic security hardening and SSH key setup"
echo -e "⭐ Advanced system logging"
echo -e "--------------------------------------------------------"
echo -e "If you like the project star ⭐ it on GitHub and report"
echo -e "issues using the 'Issues' feature on the repository"
echo -e "--------------------------------------------------------"

echo -e "${NC}"

# -------------------------------------------------------------------------------------------
echo "🔁 Updating repositories & packages..."
# Update / upgrade part
apt update &>/dev/null && apt upgrade -y &> /dev/null

echo "⬇️ Installing required packages..."
# Required packages installation
apt install whois curl git -y &> /dev/null

# -------------------------------------------------------------------------------------------
echo "🚫 Disabling Snap Services..."
# Disabling Snap Services
find /etc/systemd/system -maxdepth 2 -name 'snap*' -exec basename -z {} \; \
| sort -uz | xargs -r0 systemctl disable &> /dev/null

# -------------------------------------------------------------------------------------------
echo "🧹 Removing Ubuntu Advantage Tools..."
# Removing ubuntu-advantage-tools + deps

apt purge --autoremove ubuntu-advantage-tools -y &> /dev/null

# -------------------------------------------------------------------------------------------
echo "🧹 Removing Snap Packages..."
# Removing Snap Packages + deps
for deb in $(dpkg -l | egrep "^ii" | awk ' {print $2} ' | sort | grep snap | sed -z 's/\n/ /g')
do
apt-get purge -y $deb &>/dev/null
done
apt autoremove -y &>/dev/null

# -------------------------------------------------------------------------------------------
echo "🧹 Removing Snap and Games from PATH..."
# Removing Snap and Games from PATH
sed -i "s/\:\/snap\/bin//g" /etc/environment | \
sed -i "s/\:\/usr\/local\/games//g" /etc/environment | \
sed -i "s/\:\/usr\/games//g" /etc/environment

# -------------------------------------------------------------------------------------------
echo "🔄 Restarting the SSH server..."
# Restarting the SSH server

systemctl restart sshd -y &> /dev/null

# -------------------------------------------------------------------------------------------
echo "🔧 Configuring automatic security updates..."
# Configuring automatic security updates

apt install unattended-upgrades -y &> /dev/null
echo "🛠️ Configuring automatic reboots for automatic security updates..."
apt install apt-config-auto-update -y &> /dev/null

systemctl enable unattended-upgrades &> /dev/null
systemctl stop unattended-upgrades &> /dev/null

read -p "📩 Enter an email address for updates errors notifications: " "user_email"

sed -i "s/Unattended-Upgrade\:\:Mail .*/Unattended-Upgrade\:\:Mail \"${user_email}\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:MailReport.*/Unattended-Upgrade\:\:MailReport \"only-on-error\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:Remove-New-Unused-Dependencies.*/Unattended-Upgrade\:\:Remove-New-Unused-Dependencies \"true\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:Automatic-Reboot.*/Unattended-Upgrade\:\:Automatic-Reboot \"true\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:Automatic-Reboot-WithUsers.*/Unattended-Upgrade\:\:Automatic-Reboot-WithUsers \"false\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:Automatic-Reboot-Time.*/Unattended-Upgrade\:\:Automatic-Reboot-Time \"04:00\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades
sed -i "s/Unattended-Upgrade\:\:SyslogEnable.*/Unattended-Upgrade\:\:SyslogEnable \"true\"\;/g" /etc/apt/apt.conf.d/50unattended-upgrades

systemctl start unattended-upgrades &> /dev/null

# -------------------------------------------------------------------------------------------
echo "🔧 Configuring Log Rotation..."
# Configuring Log Rotation

apt-get install logrotate -y &> /dev/null

cat <<'EOF' > /etc/logrotate.d/alternatives
/var/log/alternatives.log {
        daily
        rotate 14
        compress
        delaycompress
        missingok
        notifempty
        create 644 root root
                dateext
                dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/apport
/var/log/apport.log {
       daily
       rotate 14
       delaycompress
       compress
       notifempty
       missingok
           dateext
           dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/apt
/var/log/apt/term.log {
  rotate 14
  daily
  compress
  missingok
  notifempty
  dateext
  dateformat .%Y-%m-%d
}

/var/log/apt/history.log {
  rotate 14
  daily
  compress
  missingok
  notifempty
  dateext
  dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/bootlog
/var/log/boot.log
{
    missingok
    daily
    copytruncate
    rotate 14
    notifempty
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/btmp
# no packages own btmp -- we'll rotate it here
/var/log/btmp {
    missingok
    daily
    create 0660 root utmp
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/dpkg
/var/log/dpkg.log {
        daily
        rotate 14
        compress
        delaycompress
        missingok
        notifempty
        create 644 root root
                dateext
                dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/rsyslog
/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
        rotate 14
        daily
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                /usr/lib/rsyslog/rsyslog-rotate
        endscript
                dateext
                dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/ufw
/var/log/ufw.log
{
        rotate 14
        daily
        missingok
        notifempty
        compress
        delaycompress
        sharedscripts
        postrotate
                [ -x /usr/lib/rsyslog/rsyslog-rotate ] && /usr/lib/rsyslog/rsyslog-rotate || true
        endscript
                dateext
            dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/unattended-upgrades
/var/log/unattended-upgrades/unattended-upgrades.log
/var/log/unattended-upgrades/unattended-upgrades-dpkg.log
/var/log/unattended-upgrades/unattended-upgrades-shutdown.log
{
  rotate 14
  daily
  compress
  missingok
  notifempty
  dateext
  dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/wtmp
# no packages own wtmp -- we'll rotate it here
/var/log/wtmp {
    missingok
    daily
    create 0664 root utmp
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/do-release-upgrade
/var/log/dist-upgrade/*.log
/var/log/dist-upgrade/*.txt
 {
    missingok
    daily
    create 0664 root root
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/landscape
/var/log/landscape/*.log
 {
    missingok
    daily
    create 0664 landscape landscape
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/private
/var/log/private/*.log
 {
    missingok
    daily
    create 0664 root root
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/cloud-init
/var/log/cloud-init.log
 {
    missingok
    daily
    create 0664 syslog adm
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/cloud-init
/var/log/cloud-init-output.log
 {
    missingok
    daily
    create 0664 root adm
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

cat <<'EOF' > /etc/logrotate.d/dmesg
/var/log/dmesg
 {
    missingok
    daily
    create 0640 root adm
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

systemctl restart logrotate.service &>/dev/null

# -------------------------------------------------------------------------------------------
echo "🛠️ Installing fail2ban and configuring SSH jail..."
# Fail2ban + SSH jail config

apt-get install fail2ban -y &>/dev/null
systemctl enable fail2ban &>/dev/null
systemctl stop fail2ban &>/dev/null


cat <<'EOF' > /etc/fail2ban/fail2ban.d/loglevel.conf
loglevel = ERROR
EOF

sleep 1

cat <<'EOF' > /etc/fail2ban/jail.d/ssh.conf.local
[sshd]
 enabled = true
 port = ssh
 filter = sshd
 logpath = /var/log/auth.log
 maxretry = 3
 bantime  = 3600
 findtime  = 300
 ignoreip = 127.0.0.1
EOF

sleep 1

cat <<'EOF' > /etc/logrotate.d/fail2ban
/var/log/fail2ban.log
 {
    missingok
    daily
    create 0640 root adm
    minsize 1M
    rotate 14
        dateext
        dateformat .%Y-%m-%d
}
EOF

sleep 1

systemctl restart logrotate.service &>/dev/null
systemctl start fail2ban &>/dev/null

clear
echo -e ""
echo -e "${BLUE}--------------------------------------------------"
echo -e "⚙️ Setup is complete, here's a summary:"
echo -e "Don't forget to star the repo at ${NC}https://fla.am/ub"
echo -e "${BLUE}--------------------------------------------------"
echo -e ""
echo -e "${BLUE}--------------------------------------------------"
echo -e "✉️ Email address for notifications:"
echo -e "${NC}${user_email}"
echo -e "${BLUE}--------------------------------------------------"
echo -e ""
echo -e "--------------------------------------------------"
echo -e "👤 User created for the SSH connection:"
echo -e "${NC}${sudo_user}"
echo -e "${BLUE}--------------------------------------------------"
echo -e ""
echo -e "--------------------------------------------------"
echo -e "🔑 Public key deployed on the server:"
if [[ -f /root/.ssh/id_ed25519.pub ]]
then
    echo -e "${public_key}"
else
    echo -e "❌ No public key was generated."
fi
echo -e "--------------------------------------------------"
echo -e ""
echo -e "${BLUE}--------------------------------------------------"
echo -e "🔑 Private key, place it on your client:"
if [[ -f /root/.ssh/id_ed25519 ]]
then
    echo -e "✅ You must use this private key to be able to connect to the server via SSH."
    echo -e ""
    echo -e "${private_key}"
else
    echo -e "❌ No private key was generated."
fi
echo -e "--------------------------------------------------${NC}"
echo -e ""
