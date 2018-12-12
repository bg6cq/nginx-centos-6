# CentOS 6.10 nginx编译和优化

CentOS本身没有nginx，epel中的nginx版本比较低，下面是CentOS 6.10 编译nginx.1.42.2并包含lua支持的步骤，最后给出一些优化的方法：

如果不愿意自己编译，可以参照"7. 使用远程 yum 源"设置科大的nginx源。

注： run.sh 文件有完整的编译过程脚本，直接运行即可。

## 1. 环境准备

下载 CentOS 6.10 x86_64 最小安装

运行如下命令，启用epel库（geoip等在epel库中），安装rpmbuild等需要的软件包

```
rpm -i https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install git gcc rpm-build rpmdevtools geoip-devel gd-devel pcre-devel
yum -y install perl-devel perl-ExtUtils-Embed libxslt-devel createrepo
yum -y update
reboot
```

## 2. 下载编译需要的文件

编译需要的文件放在 https://git.ustc.edu.cn/james/centos-nginx ，下载到默认的 /root/rpmbuild 目录

下载前该目录不能存在。如果目录已经存在，请下载到其他位置，把SOURCES、SPECS目录下文件 copy 到 /root/rpmbuild 对应目录下也可以。

```
cd /root
git clone https://git.ustc.edu.cn/james/centos-nginx.git rpmbuild
```

## 3. 编译需要的LuaJIT，并安装

编译好的文件在 /root/rpmbuild/RPMS/x86_64 目录。

```
cd /root/rpmbuild
rpmbuild -bb SPECS/LuaJIT.spec

rpm -i RPMS/x86_64/LuaJIT-2.0.5-1.el6.x86_64.rpm
```

## 4. 编译nginx

```
cd /root/rpmbuild
rpmbuild -ba SPECS/nginx.spec
```
编译好的文件在 /root/rpmbuild/RPMS/x86_64 和 /root/rpmbuild/RPMS/noarch 目录。

## 5. 搭建yum库

编译好的rpm包可以安装，但是自己手工安装需要处理依赖关系，比较麻烦。

下面是搭建yum库的方法。

```
mkdir -p /var/www/html/local-yum/x86_64/RPMS
cp /root/rpmbuild/RPMS/x86_64/* /root/rpmbuild/RPMS/noarch/* /var/www/html/local-yum/x86_64/RPMS
createrepo /var/www/html/local-yum/x86_64/
```

## 6. 使用本地yum源

如果是本地使用，建立文件 /etc/yum.repos.d/local.repo，内容为：
```
[local-yum]
name=local-yum
baseurl=file:///var/www/html/local-yum/x86_64
enabled=1
gpgcheck=0
```
之后就可以使用自己本地源。

## 7. 使用远程 yum 源

如果把 /var/www/html/local-yum/ 目录通过web服务器对外提供，其他机器只要 建立文件 local.repo 即可使用。
```
[local-yum]
name=local-yum
baseurl=http://revproxy.ustc.edu.cn:8000/local-yum/x86_64
enabled=1
gpgcheck=0
```

## 8. 系统优化

8.1 禁用SELINUX

编辑文件`/etc/selinux/config`，把`SELINUX=enforcing`修改为`SELINUX=disabled`

8.2 增加打开的文件数

编辑文件`vi /etc/security/limits.conf`，增加4行：
```
*               soft    nofile  655360
*               hard    nofile  655360
root            soft    nofile  655360
root            hard    nofile  655360
```

编辑文件`vi /etc/sysctl.conf`，增加1行:
```
fs.file-max = 655360
```

8.3 优化nf_conntrack部分

编辑文件`/etc/modprobe.d/nf_conntrack.conf`，增加一行即可把最大连接数修改为104万。
```
options nf_conntrack hashsize=131072
```

启动过程中，增加如下代码，减少conntrack超时时间：
```
cd /proc/sys/net/netfilter
echo 60 > nf_conntrack_generic_timeout
echo 10 > nf_conntrack_icmp_timeout
echo 10 > nf_conntrack_icmpv6_timeout
echo 10 > nf_conntrack_tcp_timeout_close
echo 10 > nf_conntrack_tcp_timeout_last_ack
echo 10 > nf_conntrack_tcp_timeout_time_wait
echo 10 > nf_conntrack_tcp_timeout_close_wait
echo 10 > nf_conntrack_tcp_timeout_max_retrans
echo 10 > nf_conntrack_tcp_timeout_unacknowledged
echo 600 > nf_conntrack_tcp_timeout_established
echo 60 > nf_conntrack_tcp_timeout_syn_recv
echo 10 > nf_conntrack_tcp_timeout_fin_wait
echo 30 > nf_conntrack_tcp_timeout_syn_sent
echo 10 > nf_conntrack_udp_timeout
echo 60 > nf_conntrack_udp_timeout_stream
```

## 附录：

CentOS默认的nginx之外，下载了如下软件：

* http://nginx.org/download/nginx-1.14.2.tar.gz http://nginx.org/download/nginx-1.14.2.tar.gz.asc
* http://luajit.org/download/LuaJIT-2.0.5.tar.gz
* https://www.openssl.org/source/openssl-1.1.1a.tar.gz
* https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz
* https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz
