function bannerInstall(){
 echo "########################################################################################################"
 echo "|                                                                                                      |"	
 echo "| #### #   #  ####  ######    #   #     #       ####  ###### ###### ######  ##    #   #   #####  ##### |"
 echo "|  ##  ##  # ##       ##     # #  #     #      ##     ##   # ##       ##    ## #  #  # #  ##  ## #     |"
 echo "|  ##  # # #  ####    ##    ##  # #     #       ####  ##   # ####     ##    ## #  # ##  # #####  ####  |"
 echo "|  ##  #  ##     ##   ##    ##### #     #          ## ##   # ##       ##    ## #  # ##### ##  ## #     |"
 echo "| #### #   #  ####    ##    ##  # ####  ####    ####  ###### ##       ##     ## ##  ##  # ##  ## ##### |"	
 echo "|                                                                                                      |"	
 echo "########################################################################################################"
}
function bannerdonne(){
clear
echo -e "##############################"
echo -e "| ####   #####  #   #  ##### |"
echo -e "| #   #  #   #  ##  #  #     |"
echo -e "| #   #  #   #  # # #  ####  |"
echo -e "| #   #  #   #  #  ##  #     |"
echo -e "| ####   #####  #   #  ##### |"
echo -e "##############################"
}
function exitfun() {
		echo "######################################"
		echo "| ####  #   # ####   ####  #   # #### |"
		echo "| #   #  # #  #      #   #  # #  #    |"
		echo "| ####    #   ###    ####    #   ###  |"
		echo "| #   #   #   #      #   #   #   #    |"
		echo "| ####    #   ####   ####    #   #### |"
		echo "######################################"
		exit 0
}
function isRoot() {
	if [ "$EUID" -ne 0 ]; then
		return 1
	fi
}

function initialCheck() {
	if ! isRoot; then
		echo "Sorry, you need to run this as root"
		exitfun
	fi
	checkOS
}
function checkOS() {
	
	if [[ -e /etc/system-release ]]; then
		source /etc/os-release
		if [[ $ID == "fedora" || $ID_LIKE == "fedora" ]]; then
			OS="fedora"
		fi
		if [[ $ID == "centos" || $ID == "rocky" || $ID == "almalinux" ]]; then
			OS="centos"
			if [[ ! $VERSION_ID =~ (7|8) ]]; then
				echo "⚠️ Your version of CentOS is not supported."
				echo ""
				echo "The script only support CentOS 7 and CentOS 8."
				echo ""
				exitfun
			fi
		fi
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, Amazon Linux 2, Oracle Linux 8 or Arch Linux system"
		exitfun
	fi
}
function information(){
echo "######################################################################"
echo "|                                                                    |"
echo "| #### #   # #####  ##### ####   #   #   #   ###### #### ##### #   # |"
echo "|  ##  ##  # ##     #   # #  ##  ## ##  # #    ##    ##  #   # ##  # |"
echo "|  ##  # # # ####   #   # ####   # # # #   #   ##    ##  #   # # # # |"
echo "|  ##  #  ## ##     #   # #  ##  #   # #####   ##    ##  #   # #  ## |"
echo "| #### #   # ##     ##### #   ## #   # #   #   ##   #### ##### #   # |"
echo "|                                                                    |"
echo "######################################################################"
  echo "To unban an IP: fail2ban-client unban xxx.xxx.xxx.xxx"
  echo "systemctl status fail2ban"
  echo "fail2ban-client status"
  echo "fail2ban-client status sshd"
}
function installsoft() {
bannerInstall
sudo timedatectl set-timezone Asia/Almaty
echo -e "Time zone changed to Asia-Almty"
yum install -y epel-release
yum install -y fail2ban
sudo systemctl enable fail2ban
echo "
[DEFAULT]
bantime = 36000
banaction = iptables-multiport
[sshd] 
enabled = true
logpath = /var/log/banned/jail.log

[vsftpd-iptables]

enabled  = true
filter   = vsftpd
action   = iptables[name=VSFTPD, port=ftp, protocol=tcp]
           sendmail-whois[name=VSFTPD, dest=you@example.com]
logpath  = /var/log/secure
maxretry = 4
bantime  = 259200
" > /etc/fail2ban/jail.local
touch /etc/fail2ban/filter.d/vsftpd.conf
echo "
# Fail2Ban filter for vsftp
#
[INCLUDES]
before = common.conf
[Definition]
__pam_re=\(?pam_unix(?:\(\S+\))?\)?:?
_daemon =  vsftpd
failregex = ^%(__prefix_line)s%(__pam_re)s\s+authentication failure; logname=\S* uid=\S* euid=\S* tty=(ftp)? ruser=\S* rhost=<HOST>(?:\s+user=.*)?\s*$
            ^ \[pid \d+\] \[.+\] FAIL LOGIN: Client "<HOST>"\s*$
ignoreregex =
/var/log/vsftpd.log

" >> /etc/fail2ban/filter.d/vsftpd.conf
echo "dual_log_enable=YES" >> /etc/vsftpd/vsftpd.conf

echo '
ignoreip = 127.0.0.1/8
bantime = 600
findtime = 600
maxretry = 3
' >> /etc/fail2ban/jail.conf

systemctl restart fail2ban
yum install -y lsof 
yum install -y nano
bannerdonne
}
initialCheck
installsoft
information
exitfun

