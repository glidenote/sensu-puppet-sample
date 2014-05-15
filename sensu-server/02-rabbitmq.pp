#---------------------------------------------------
# 環境に合わせて変更してください
#---------------------------------------------------
$rabbitmq_password = 'mypass' # 03-sensu-server.ppと同じにしてください
#---------------------------------------------------

include 'erlang'

class { 'rabbitmq':
  ssl_key           => '/etc/rabbitmq/ssl/key.pem',
  ssl_cert          => '/etc/rabbitmq/ssl/cert.pem',
  ssl_cacert        => '/etc/rabbitmq/ssl/cacert.pem',
  ssl               => true,
  delete_guest_user => true,
}
-> rabbitmq_vhost { '/sensu': }
-> rabbitmq_user  { 'sensu': password => "$rabbitmq_password" }
-> rabbitmq_user_permissions { 'sensu@/sensu':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
}
