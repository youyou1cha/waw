# shell学习笔记

##### shell基础

1、赋值

```shell
#和其他语言赋值不一样。再shell中空格有其他含义。赋值的等号两边不能有空格。python中赋值就可以随意空格。shell和python都不需要定义类型。属于解释性语言；
#开头都需要引用解释器
#!/bin/env bash
#env 是shell中的环境变量，可以利用env调用bash
A="hello world"
#单引号 双引号结果看起来一样
#调用变量需要用$
#区分大小写
echo $A
echo $(A)
A_test=$(uname-r)

#declare
declare -i A=123
declare -A NAME
declare -a name
declare -x jre_name
```

2、循环控制语句

```shell
#判断 if 
# [] 判断语句两边都有空格
if [ 判断语句 ];then
do
	如果是真command
else
	假cmmand
done
#for
for i in a b c d e
do
	echo $i
done
#for类C
for (( i=0;i<=10;i++ ))
do
	echo $i
done
#for也可以用调用位置参数
#位置参数 $0 $1 $2...$10 
for i
do
	echo $i
done
#如果想遍历命令结果，可以用``引起来。也可以用${}获取结果。

#调试shell用bash -x *.sh

#while
sum=0;while( sum<10 );do echo $sum let sum++;done

#until 条件是假进入循环。真推出循环 why有这样的设计？
# break continue exit
```

3、四则运算

```shell
#加减乘除
echo $((1+1))
echo $[1*2]
#使用上面两个[](())有点用判断test或者if后面的判断句的一样写法。至少前面加上$
#expr let
expr 10 / 5 #注意。/前后有空格
expr 10 - 2
#let
let n++
n=10;let n=$n**2;echo $n
#bc
echo 1+1.5|bc
```



4、函数

```shell
function name(){
command1
....
}
#function调用参数
function aa(){
name $1
echo $name
}
input_sh(){
	out=$1
	input=""
	while [ -z $input ]
	do
		read -p "请输入out:" input
	done
	echo $input
}
name=`input_sh 请输入姓名:`
age=`input_sh 请输入性别:`
echo $name;echo $age
```

5、sed

``` shell
#-e -r -f
#print/p a/append i/insert change/c d/delete
#这些语法一样
sed '5i9999' a.txt
#打印 1-5行
sed -n '1,5p' /etc/passwd
#正则
sed -rn '1,10/^root/p' /etc/passwd
#替换
sed -n 's/^root/ROOT/gp' /etc/passwd
```

6、awk

```shell
#打印列
ll |awk '{print $1}'
#打印行
awk 'NR==1,NR==5{print $0}' filename
#统计
awk 'BEGIN{shell[$NF]++}{for i in shell {print i,shell[i]}}'
```

7、数组

```shell
#普通数组
#赋值
arrary[0]=str1;arrary[1]=str2;arrary[2]=str3
array=(var1 var2 var3 var4)
arrary1=`ls /root`
arrary2=`cat /etc/passwd`
arrar=(harry amy jack "miss you")
arstr=(1 2 3 4 5 6 "hello world" [10]=linux)
#获取内容
${数组名[元素表下标]}
echo ${arstr[1]}
echo ${arstr[*]} # ${arstr[@]}
echo ${!arstr[*]} #${arstr[@]}
echo ${#arstr[*]} #元素个数
#切片
echo ${arstr[*]:1:2}
#关联数组
declare -A asso_array1
#关联数组赋值
asso_array1[linux]=one
asso_array=([linux]=one [php]=two)
let asso_array[linux]++
#案例
declare -A array_status
status=`ss -ant|grep 80|cut -d " " -f1`
for i in $status
do
	let arry_status[$i]++
done
for j in ${!array_status[*]}
do
	echo $j:${arry_status[$j]}
done
```

8、正则

```shell
#元字符
. * $ ^ [] + ? | () {n,m}
#常用
.* ^$ ^[^a]
```

9、expect

```shell
#expect是很好用的东西
#我的理解是看到某个东西，交互shell
#!/usr/bin/expect
set ip 192.168.48.131
set pass 12345
set timeout 5
spawn ssh root@$ip
expect {
	"(yes/on)?" {send "yes\r";exp_continue}
	"password:" {send "$passw\r"}
}
interact
 #!/usr/bin/expect
 set ip 1.1.1.1
 set pass 123456
 set  timeout 5
 spawn ssh root@$ip
 expect {
 	"(yes/no)？" {send "yes\r";exp_continue}
 	"passwd:" {send "123456\r"}
 }
 expect "#"
 send "date\r"
 send "ls /tmp\r"
 send "touch /tmp/file{1..3}\r"
 send "echo date +%F" >> tmp.log
 send "exit\r"
 expect eof
 
 #w位置参数
 set ip [ lindex $argv 0 ]
 set ip [ lindex $argv 1 ]
 
 #shell嵌入expect
 [ -f /home/yunwei/.ssh/id_rsa ] && ssh-keygen -P '' -f ./id_rsa
 
 tr ':' ' ' </shell04/ip.txt|while read ip pass
 do
 {
 	ping -c1 $ip &>/dev/null
 	if [ $? -eq 0 ];then
 	echo $ip >> ~/ip_up.txt
 	/usr/bin/expect <<-END
	spawn ssh-copy-id root@$ip
	expect {
			"(yes/no?)" {send "yes\r";exp_continue}
			"password:" {send "$pass\r"}
	}
	expect eof
	fi

END
 }&
 
 done
 wait
 remote_ip=$(tail -1 ~/ip_up.txt)
 ssh root@remote_ip hostname &>/dev/null
 test $? -eq 9 && echo '1'
```

10、输入输出

```shell
#输入
read -p "请输入：" name
echo $name
read -p "请输入其他ip:" ip < ip.txt
#输入
echo $name >> name.txt

read -p "请输入一个字符：" str1
[[ $str1 == "haha" ]] && echo "my haha" || echo "you haha"
```

11、环境变量

```shell
#三个目录
bashrc bash_profile /etc/bashrc /etc/profile
#定义
export
declare -X
```

12、内置变量 位置参数

```shell
$0 #整个命令行
$1..$10..${11} #位置参数
$* #all 所有参数 []
$@ #all 输出方式不用一$*
$? #上一个命令的返回值；0代表成功 其他再说。函数可以自定义return 返回值
$$ #当前正在运行的进程
$! #上一个后台的进程号
!$ #上一个进程的参数
```

13、条件判断

```shell
#语法格式
test 表达式
[ 表达式 ]
[[ 表达式 ]]
#表达式
command -a commamd1 # and
express1 -o express2 # or
#string
-n string #nonzone 不空
-z string  # zero 空
string1 = string2 #equal
string != string2 #not equal
#整数
integ -eq integ2 #equal
integer -ge integer # greater and equal
integer -gt integer # greater than
integer -le integer # less equal
integer -lt integer # less than
integer -ne integer #not equal

#file
file -ef file #equal file
file -nt file #new than
file -ot file2 #older than

#file 类型
-d  file #directory
-e file # exists
-f file #file and exists
-w file
-x file
```

14、其他

```shell
#切片
{1..100..2}  #切片
echo {1..100..2}|tr -d " " #tr -d 删删除空格
echo {a..z}|tr -d " " #
seq 100 2 1 # 中间的2是步长

time + sh 可以看时间

shift #左移参数。不知道用的多不多

jobs -l #看后台

#信号 1 2 9 3 15 18 19 20
```

15、字符串合并截取

```shell
#！/bin/bash
name="shell"
url="http://1111.com"
str1=$name$url  #中间不能有空格
str2="$name $url" #引起来就没事了
str3=$name ": " $url #合并
str4="$name : $url" #这样也可以
str5="${name}Script:${url}index.htmt" #so do this

#截取
# #从左往右删 一个#是删除第一个 两个是最后 前面用*代表全部元素
##*// #*/  %//* %/*
var=http://www.aaa.com//123.html
echo ${var#*//}
echo ${var##*//}
echo ${var%//*}
echo ${var%%//*}

echo ${var:7}
echo ${var:1:5}
echo ${var:0-7:3} #右往左 最后3代表一共3个字符
echo ${var:0-7} #后面7个字符

#替换  / //贪婪模式
echo ${url/ao/AO}
echo ${url//ao/AO}
```

16、case

```shell
#!/bin/env bash
case $1 in
	start|S)
	echo "/etc/init.d/mysql start"
	;;
	stop|T)
	echo "/etc/init.d/mysql stop"
	;;
	reload|R)
	echo "/etc/init.d/mysql restart"
	;;
	*)
	echo "Nothin is done"
	;;
esac
read -p "请输入管理的服务，例如vsftpd：" service
case $service in

```

