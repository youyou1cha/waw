#!/bin/env bash
#
# 修改ssh端口 禁ping
#

# 查看firewall状态
# 
systemctl status firewalld.service
systemctl stop firewalld.service
systemctl disable firewalld.service
# 禁ping
cat /etc/sysctl.conf |grep -E "^net.*icmp.*"
[ $? -eq 0 ] &&  sed -r -i 's/(^net.*)=0/\1=1/g' /etc/sysctl.conf || echo "net.ipv4.icmp_echo_ignore_all=1" >> /etc/sysctl.conf
sysctl -p
ping -c1 127.0.0.1
[ $? -ne 0 ] && echo "success" || echo "not success"

# 修改ssh端口
sed -nr 's/^[#P]Port.*22/Port 12345/gp' /etc/ssh/sshd_config
systemctl restart sshd.service
sed -n '/^Port.*[1-9]/p' /etc/ssh/sshd_config
pida=`ps -ef |grep "/usr/sbin/sshd"|grep -v "grep"|awk '{print $2}'`
netstat -anp|grep $pida
