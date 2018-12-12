#!/bin/bash
rpm -i https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y install git gcc rpm-build rpmdevtools geoip-devel gd-devel pcre-devel
yum -y install perl-devel perl-ExtUtils-Embed libxslt-devel createrepo
yum -y update

cd /root
git clone https://git.ustc.edu.cn/james/centos-nginx.git rpmbuild

cd /root/rpmbuild
rpmbuild -bb SPECS/LuaJIT.spec

rpm -i RPMS/x86_64/LuaJIT-2.0.5-1.el6.x86_64.rpm

cd /root/rpmbuild
rpmbuild -ba SPECS/nginx.spec

