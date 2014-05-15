#---------------------------------------------------
# 環境に合わせて変更してください
#---------------------------------------------------
$rabbitmq_host     = '192.168.33.10' # sensu-serverのIPアドレス。hostnameでも可
$rabbitmq_password = 'mypass' # RabbitMQのパスワード
#---------------------------------------------------


class { 'sensu':
  server                   => false,
  dashboard                => false,
  api                      => false,
  purge_config             => true,
  rabbitmq_host            => "$rabbitmq_host",
  rabbitmq_password        => "$rabbitmq_password",
  # rabbitmq_port            => 5671, # SSL用portは5671
  # rabbitmq_ssl_private_key => 'puppet:///modules/sensu-misc/etc/sensu/ssl/key.pem',
  # rabbitmq_ssl_cert_chain  => 'puppet:///modules/sensu-misc/etc/sensu/ssl/cert.pem',
  subscriptions            => 'sensu-test',
  plugins                  => [
    'puppet:///modules/sensu-misc/etc/sensu/plugins/processes/check-procs.rb',
  ]
}

Sensu::Check {
  handlers     => 'mailer',
  subscribers  => 'web_server',
  interval     => 60,
  custom => {
    refresh     => 600,
    occurrences => 2,
  },
}

sensu::check { 'check_crond_process':
  command     => '/etc/sensu/plugins/check-procs.rb -p crond -C 1',
}

sensu::check { 'check_ssh_port':
  command     => '/usr/lib64/nagios/plugins/check_ssh -p 22 localhost',
}

#  sensu::check { '...':
#    ...
#  }

package { 'sensu-plugin': ensure   => latest, provider => 'gem'; }

package{
  'git': ;
  'nagios-plugins-ssh': ;
}

# sensu-community-pluginsの導入
exec { 'git clone sensu-community-plugins':
  user    => 'root',
  cwd     => '/tmp',
  path    => ['/usr/bin'],
  command => 'git clone https://github.com/sensu/sensu-community-plugins',
  creates => '/tmp/sensu-community-plugins',
  require => Package['git'],
}

exec { 'rsync sensu-community-plugins':
  user    => 'root',
  path    => ['/usr/bin'],
  command => 'rsync -av /tmp/sensu-community-plugins/ /etc/puppet/modules/sensu-misc/files/etc/sensu/',
  creates => '/etc/puppet/modules/sensu-misc/files/etc/sensu/plugins/aws',
  require => Exec['git clone sensu-community-plugins'],
}
