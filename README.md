# CentOS 6.10 编译nginx

epel中的nginx版本比较低，下面是CentOS 6.10 编译nginx.1.42.2并包含lua支持的步骤：

## 1. 系统准备

首先下载 CentOS 6.10 x86_64 最小安装

## 2. 环境准备

包括启用epel库（geoip等在epel库中），安装rpmbuild等需要的软件包

```
rpm -i https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install git gcc rpm-build rpmdevtools geoip-devel gd-devel pcre-devel
yum -y install perl-devel perl-ExtUtils-Embed libxslt-devel
yum update
reboot
```

## 3. 下载编译需要的文件

编译需要的文件放在 https://git.ustc.edu.cn/james/centos-nginx ，下载到默认的 /root/rpmbuild 目录

下载前该目录不能存在。如果目录已经存在，请下载到其他位置，把SOURCES、SPECS目录下文件 copy 到 /root/rpmbuild 对应目录下也可以。

```
cd /root
git clone https://git.ustc.edu.cn/james/centos-nginx rpmbuild
```

## 4. 编译需要的LuaJIT，并安装

编译好的文件在 /root/rpmbuild/RPMS/x86_64 目录。

```
cd /root/rpmbuild
rpmbuild -bb SPECS/LuaJIT.spec

rpm -i RPMS/x86_64/LuaJIT-2.0.5-1.el6.x86_64.rpm
```

## 5. 编译nginx

```
cd /root/rpmbuild
rpmbuild -ba SPECS/nginx.spec
```
编译好的文件在 /root/rpmbuild/RPMS/x86_64 和 /root/rpmbuild/RPMS/noarch 目录。


## 附录：

CentOS默认的nginx之外，下载了如下软件：

* http://nginx.org/download/nginx-1.14.2.tar.gz http://nginx.org/download/nginx-1.14.2.tar.gz.asc
* http://luajit.org/download/LuaJIT-2.0.5.tar.gz
* https://www.openssl.org/source/openssl-1.1.1a.tar.gz
* https://github.com/simplresty/ngx_devel_kit/archive/v0.3.0.tar.gz
* https://github.com/openresty/lua-nginx-module/archive/v0.10.13.tar.gz
