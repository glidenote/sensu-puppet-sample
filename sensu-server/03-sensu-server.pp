#---------------------------------------------------
# 環境に合わせて変更してください
#---------------------------------------------------
$dashboard_user     = 'admin'  # sensu dashboardへのログインユーザ名
$dashboard_password = 'secret' # sensu dashboardへのログインパスワード
$rabbitmq_password  = 'mypass' # rabbitmqのパスワード。02-rabbitmq.ppのパスワードと同じにしてください
$mailer_mail_from   = 'sensu+alert@foobar.com' # アラートメールのfrom address
$mailer_mail_to     = 'mail@foobar.com' # アラートメールのto address
$mailer_smtp_domain = 'foobar.com' # アラートメールのdomain
#---------------------------------------------------

class { 'sensu':
  server                   => true,
  dashboard                => true,
  api                      => true,
  purge_config             => true,
  dashboard_user           => "$dashboard_user",
  dashboard_password       => "$dashboard_password",
  rabbitmq_password        => "$rabbitmq_password",
  rabbitmq_ssl_private_key => 'puppet:///modules/sensu-misc/etc/sensu/ssl/key.pem',
  rabbitmq_ssl_cert_chain  => 'puppet:///modules/sensu-misc/etc/sensu/ssl/cert.pem',
  rabbitmq_host            => 'localhost',
  rabbitmq_port            => 5671, # SSL用portは5671
  subscriptions            => 'sensu-test',
  plugins                  => [
    'puppet:///modules/sensu-misc/etc/sensu/plugins/processes/check-procs.rb',
  ]
}

sensu::check { 'check_crond_process':
  command     => '/etc/sensu/plugins/check-procs.rb -p crond -C 1',
  handlers    => 'mailer',
  subscribers => 'sensu-test'
}

sensu::handler { 'mailer':
  type        => 'pipe',
  source      => 'puppet:///modules/sensu-misc/etc/sensu/handlers/notification/mailer.rb',
  config      => {
    mail_from     => "$mailer_mail_from",
    mail_to       => "$mailer_mail_to",
    smtp_address  => 'localhost',
    smtp_port     => 25,
    smtp_domain   => "$mailer_smtp_domain",
  },
  require => Exec['rsync sensu-community-plugins'],
}

package {
  'sensu-plugin':
    ensure   => latest,
    provider => 'gem';

  # mailer.rbで利用
  'mail':
    ensure   => latest,
    provider => 'gem';
}

# sensu-community-pluginsのインストール
package{ 'git': }

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
