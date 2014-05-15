#!/bin/sh

#---------------------------------------------------
# 環境に合わせて変更してください
#---------------------------------------------------
YOUR_DOMAIN="foobar.com"
#---------------------------------------------------

if [ -f "/var/vagrant_provision" ]; then 
  exit 0
fi

# sensu-puppetがこけるので追加
echo "domain ${YOUR_DOMAIN}" >> /etc/resolv.conf

rpm -ivh http://ftp-srv2.kddilabs.jp/Linux/distributions/fedora/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
yum -y install puppet rubygem-json jq

# 存在しないpuppetが毎回warningを出すので用意
touch /etc/puppet/hiera.yaml

# puppet module をインストール
puppet module install sensu/sensu

# sensu-community-plugins を設置するディレクトリを用意
mkdir -p /etc/puppet/modules/sensu-misc/files/etc/sensu/

touch /var/vagrant_provision
