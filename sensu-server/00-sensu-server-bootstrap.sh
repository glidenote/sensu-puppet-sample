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
yum -y install puppet rubygem-json jq openssl wget

# puppet module をインストール
puppet module install fsalum-redis --version 0.0.12
puppet module install puppetlabs-rabbitmq --version 3.1.0
puppet module install sensu-sensu --version 1.0.0

# 存在しないpuppetが毎回warningを出すので用意
touch /etc/puppet/hiera.yaml

# http://sensuapp.org/docs/0.12/certificates の公式ツールを利用して
# RabbitMQとSensuで利用するSSL証明書を作成
cd /tmp
wget http://sensuapp.org/docs/0.12/tools/ssl_certs.tar
tar -xvf ssl_certs.tar
cd ssl_certs
./ssl_certs.sh generate

# RabbitMQで利用するSSL証明書を設置
mkdir -p /etc/rabbitmq/ssl
cp /tmp/ssl_certs/sensu_ca/cacert.pem /etc/rabbitmq/ssl/
cp /tmp/ssl_certs/server/cert.pem /etc/rabbitmq/ssl/
cp /tmp/ssl_certs/server/key.pem /etc/rabbitmq/ssl/

# Sensuで利用するSSL証明書を設置
mkdir -p /etc/puppet/modules/sensu-misc/files/etc/sensu/ssl/
cp /tmp/ssl_certs/client/cert.pem /etc/puppet/modules/sensu-misc/files/etc/sensu/ssl/
cp /tmp/ssl_certs/client/key.pem /etc/puppet/modules/sensu-misc/files/etc/sensu/ssl/

touch /var/vagrant_provision
