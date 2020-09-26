# NGINX  high performance web server



[TOC]



## 是什么

nginx是一个高性能的HTTP容器。

2、能做什么

- 负载均衡
- 反向代理、正向代理
- 静态文件解析
- HTTP容器

## nginx安装

```shell
#在linux下面效率高于win很多。建议在linux下面学习，测试
#通过yum安装，测试机器版本是centos 7.7。
#通过yum安装可以集成到systemctl管理nginx
#systenctl stop|start|restart|enable nginx
yum -y install nginx

#下面用编译安装nginx，可以自定义模块。
#1、下载解压文件
wget http://nginx.org/download/nginx-1.19.2.tar.gz && tar -xzvf nginx-1.19.2.tar.gz -C /home/nginx
#2、安装依赖
yum install -y pcre-devel 
yum -y install gcc make gcc-c++ wget
yum -y install openssl openssl-devel 
#3、编译安装
cd /home/nginx 
./configure
make && make install
# 如果有报错“C compiler cc is not found”。缺少gcc编译环境。yum -y install gcc make gcc-c++
```

## 卸载nginx

```shell
1、yum安装
yum remove nginx
2、编译安装
rm -rf /usr/local/nginx #直接删除nginx目录就可以了。nginx默认安装/usr/local/nginx
```

## 测试nginx

```shell
cd /usr/local/nginx/sbin
./nginx -t
```

![image-20200924104435657](C:\Users\waw\AppData\Roaming\Typora\typora-user-images\image-20200924104435657.png)

## 添加到环境变量

```shell
把/usr/local/nginx/sbin/加到bash_profile就可以了。
sed -r -i 's/(^PATH.*$)/\1:\/usr\/local\/nginx\/sbin\//g' ~/.bash_profile
source ~/.bash_profile
[root@localhost nginx]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

## 开机启动

```shell
cat /lib/systemd/system/nginx.service

#unit 服务说明 英语好了真的天然的优势--/(ㄒoㄒ)/~~
[Unit]
Description=nginx - high performance web server
Documentation=http://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
#后台 forking
Type=forking
PIDFile=/var/run/nginx.pid
#运行
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
# 信号 HUP 和TERM区别
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target

#开机启动
systemctl enable nginx.service
#启动
systemctl start nginx.service
#重启
systemctl restart nginx.service
#状态
systemctl status nginx.service
#停止开机启动
systemctl disable nginx.service
#查看以后服务
systemctl list--units --type=service |grep nginx

#rc.local开启启动也可以
echo '/usr/local/nginx/sbin/nginx start' >> /etc/rc.local
```

## 常用命令

```shell
#启动
nginx
/usr/local/nginx/sbin/nginx
#重启
/usr/local/nginx/sbin/nginx -s stop
/usr/local/nginx/sbin/nginx
#重新加载配置
/usr/local/nginx/sbin/nginx -s reload
#停止
/usr/local/nginx/sbin/nginx -s stop
#平滑关闭
/usr/local/nginx/sbin/nginx -s quit
#状体
/usr/local/nginx/sbin/nginx -V
```

## 防火墙

```shell
1、关闭防火墙
systemctl disable firewalld.service
systemctl stop firewalld.service
1、iptables规则
iptables -A INPUT -m state --state NEW -m tcp -p tcp --drpot $port -j ACCEPT
```

## 模块

如果新增模块，需要重新卸载编译安装

## nginx信号

常用的几个信号了解一下

| Signal | Description                           | command                      |
| ------ | ------------------------------------- | ---------------------------- |
| TERM   | Quick shutdown                        | nginx -s stop                |
| QUIT   | graceful shutdown                     | nginx -s quit                |
| KILL   | Halts a stubborn process              | systemctl kill nginx.service |
| HUP    | configuration reload                  | nginx -s reload              |
| USR1   | reopen the log file                   |                              |
| USR2   | upgrade executable on the fly         |                              |
| WHICH  | gracefully shutdown worker preocesses |                              |

## nginx.conf结构

```shell
main        # 全局配置，对全局生效
├── events  # 配置影响 Nginx 服务器或与用户的网络连接
├── http    # 配置代理，缓存，日志定义等绝大多数功能和第三方模块的配置
│   ├── upstream # 配置后端服务器具体地址，负载均衡配置不可或缺的部分
│   ├── server   # 配置虚拟主机的相关参数，一个 http 块中可以有多个 server 块
│   ├── server
│   │   ├── location  # server 块可以包含多个 location 块，location 指令用于匹配 uri
│   │   ├── location
│   │   └── ...
│   └── ...
└── ...
```

```bash
#nginx.conf样例
#匹配
1、= 精确匹配路径
2、^~ 不包含
3、~ 区分大小写 匹配后面正则
4、~* 不区分大小写 匹配后面正则
```

## 一些案例的配置文件

### 简单配置

```bash
server{
	listen       80;
	server_name  baidu.com app.baidu.com;
	index        index.html index.htm;
	root		 /home/www.app.baidu.com;
}
```

### 反向代理

```shell
server{
	listen		80;
	server_name	localhost;
	cilent_max_body_size	1024; #允许客户端请求的最大单字节文件字节数；
	
	localtion / {
		proxy_pass 				http://localhost:8080 
		proxy_set_header Host   $host:$server_port
		proxy_set_header X-Forwarded-For  $remote_addr # HTTP请求真实IP
		proxy_set_header X-Forwarded-Proto $scheme  #为了正确地识别实际用户发出的协议是 http 还是 https
	}
}

server {
    #侦听的80端口
    listen       80;
    server_name  git.example.cn;
    location / {
        proxy_pass   http://localhost:3000;
        #以下是一些反向代理的配置可删除
        proxy_redirect             off;
        #后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
        proxy_set_header           Host $host;
        client_max_body_size       10m; #允许客户端请求的最大单文件字节数
        client_body_buffer_size    128k; #缓冲区代理缓冲用户端请求的最大字节数
        proxy_connect_timeout      300; #nginx跟后端服务器连接超时时间(代理连接超时)
        proxy_send_timeout         300; #后端服务器数据回传时间(代理发送超时)
        proxy_read_timeout         300; #连接成功后，后端服务器响应时间(代理接收超时)
        proxy_buffer_size          4k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
        proxy_buffers              4 32k; #proxy_buffers缓冲区，网页平均在32k以下的话，这样设置
        proxy_busy_buffers_size    64k; #高负荷下缓冲大小（proxy_buffers*2）
    }
}
```

### 负载均衡

```shell
upstream gitlab {
    ip_hash;
    # upstream的负载均衡，weight是权重，可以根据机器配置定义权重。weigth参数表示权值，权值越高被分配到的几率越大。
    server 192.168.122.11:8081 ;
    server 127.0.0.1:82 weight=3;
    server 127.0.0.1:83 weight=3 down;
    server 127.0.0.1:84 weight=3; max_fails=3  fail_timeout=20s;
    server 127.0.0.1:85 weight=4;;
    keepalive 32;
}
server {
    #侦听的80端口
    listen       80;
    server_name  git.example.cn;
    location / {
        proxy_pass   http://gitlab;    #在这里设置一个代理，和upstream的名字一样
        #以下是一些反向代理的配置可删除
        proxy_redirect             off;
        #后端的Web服务器可以通过X-Forwarded-For获取用户真实IP
        proxy_set_header           Host $host;
        proxy_set_header           X-Real-IP $remote_addr;
        proxy_set_header           X-Forwarded-For $proxy_add_x_forwarded_for;
        client_max_body_size       10m;  #允许客户端请求的最大单文件字节数
        client_body_buffer_size    128k; #缓冲区代理缓冲用户端请求的最大字节数
        proxy_connect_timeout      300;  #nginx跟后端服务器连接超时时间(代理连接超时)
        proxy_send_timeout         300;  #后端服务器数据回传时间(代理发送超时)
        proxy_read_timeout         300;  #连接成功后，后端服务器响应时间(代理接收超时)
        proxy_buffer_size          4k; #设置代理服务器（nginx）保存用户头信息的缓冲区大小
        proxy_buffers              4 32k;# 缓冲区，网页平均在32k以下的话，这样设置
        proxy_busy_buffers_size    64k; #高负荷下缓冲大小（proxy_buffers*2）
        proxy_temp_file_write_size 64k; #设定缓存文件夹大小，大于这个值，将从upstream服务器传
    }
}


upstream test {
    server localhost:8080;
    server localhost:8081;
}
server {
    listen       81;
    server_name  localhost;
    client_max_body_size 1024M;
 
    location / {
        proxy_pass http://test;
        proxy_set_header Host $host:$server_port;
    }
}
```

### 白名单黑名单

```shell
include  blockip.conf;
#目录 nginx.conf相同目录，在nginx.conf include /usr/bin/nginx/*.conf
deny 165.91.122.67;

deny IP;   # 屏蔽单个ip访问
allow IP;  # 允许单个ip访问
deny all;  # 屏蔽所有ip访问
allow all; # 允许所有ip访问
deny 123.0.0.0/8   # 屏蔽整个段即从123.0.0.1到123.255.255.254访问的命令
deny 124.45.0.0/16 # 屏蔽IP段即从123.45.0.1到123.45.255.254访问的命令
deny 123.45.6.0/24 # 屏蔽IP段即从123.45.6.1到123.45.6.254访问的命令

# 如果你想实现这样的应用，除了几个IP外，其他全部拒绝
allow 1.1.1.1; 
allow 1.1.1.2;
deny all; 

#http, server, location, limit_except语句中都行
```

