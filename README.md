# sensu-puppet-sample

sensu-puppetを利用して、sensuを導入出来ます。導入環境はCentOS 6.xを想定しています。

## ファイル構成

 * `sensu-server`ディレクトリ内に入っているファイルがサーバ側で実行するファイル
 * `sensu-client`ディレクトリ内に入っているファイルがクライアント側で実行するファイル

```
sensu-puppet-sample
├── README.md
├── Vagrantfile
├── sensu-client
│   ├── 00-sensu-client-bootstrap.sh
│   └── 01-sensu-client.pp
└── sensu-server
    ├── 00-sensu-server-bootstrap.sh
    ├── 01-redis.pp
    ├── 02-rabbitmq.pp
    └── 03-sensu-server.pp
```

## 準備

各ファイル内で環境に合わせて変更する値があるので適時変更してください

### sensu-server側

 * 00-sensu-server-bootstrap.sh
   * `YOUR_DOMAIN` サーバのドメイン
 * 02-rabbitmq.pp
   * `$rabbitmq_password` RabbitMQのパスワード
 * 03-sensu-server.pp
   * `$dashboard_user` sensu dashboardへのログインユーザ名
   * `$dashboard_password` sensu dashboardへのログインパスワード
   * `$rabbitmq_password` RabbitMQのパスワード
   * `$mailer_mail_from` アラートメールのfrom address
   * `$mailer_mail_to` アラートメールのto address
   * `$mailer_smtp_domain` アラートメールのdomain

### sensu-client側の設定

 * 00-sensu-client-bootstrap.sh
   * `YOUR_DOMAIN` サーバのドメイン
 * 01-sensu-client.pp
   * `$rabbitmq_host` sensu-serverのIPアドレス。hostnameでも可
   * `$rabbitmq_password` RabbitMQのパスワード

## vagrantを利用していない場合

このrepoをclone

``` sh
git clone https://github.com/glidenote/sensu-puppet-sample
```

### サーバ側作業

下記のように実行

```
sh sensu-server/00-sensu-server-bootstrap.sh
puppet apply sensu-server/01-redis.pp
puppet apply sensu-server/02-rabbitmq.pp
puppet apply sensu-server/03-sensu-server.pp
```

http://SERVER_IP:8080にアクセスするとsensu dashboardにログイン出来ます。

### クライアント側作業

下記のように実行

```
sh sensu-client/00-sensu-client-bootstrap.sh
puppet apply sensu-client/01-sensu-client.pp
```

クライアントの監視が開始されます。

## vagrantを利用している場合

 * Vagrantfile 内の`server.vm.hostname`を適時変更してください。 

```
vagrant up
```

http://192.168.33.10:8080 にアクセスするとsensu dashboardにログインできます。

## 動作の確認

両サーバとも`crond`のプロセス監視が入っているので、どちらかで

``` sh
service crond stop
```

を実行して、ダッシュボード上でのアラート表示、アラートメールが送信されるか確認。

``` sh
service crond start
```

でプロセスを直して、ダッシュボード上の表示が消えるか、リカバリーメールが送信されるか確認。

## 補足事項

### serverとclient間のRabbitMQ通信をSSL化

 * serverとclient間でRabbitMQの通信でSSLを利用する場合は、server側の`/etc/puppet/modules/sensu-misc/files/etc/sensu/ssl`内のファイルをclient側の同じディレクトリに転送し、`sensu-client/01-sensu-client.pp`内の

```
  # rabbitmq_port            => 5671, # SSL用portは5671
  # rabbitmq_ssl_private_key => 'puppet:///modules/sensu-misc/etc/sensu/ssl/key.pem',
  # rabbitmq_ssl_cert_chain  => 'puppet:///modules/sensu-misc/etc/sensu/ssl/cert.pem',
```

のコメントアウトを外すことで利用出来ます。

### ログを確認する

 * Sensuのログはjson形式で出力されるため下記のように`jq`を利用すると便利です。

```
tail -f /var/sensu/sensu-cleint.log | jq .
```
