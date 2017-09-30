[![Gem Version](https://badge.fury.io/rb/allinpay.svg)](https://badge.fury.io/rb/allinpay)

## 通联支付Ruby接口

### 安装

将以下代码添加到 Gemfile:

```ruby
gem 'allinpay'
```

然后执行

    $ bundle

或者直接运行以下命令安装:

    $ gem install allinpay

### 使用

在Rails中使用, 需要将以下代码添加到config/initializers/allinpay.rb中

```ruby
require 'allinpay'

options = {
  merchant: '商户号',
  username: '用户名: 商户号 + 02',
  password: '登录密码',
  env: '使用环境',
  private_path: '私钥文件',
  private_password: '私钥密码',
  public_path: '公钥文件'
}

$allinpay_client = Allinpay::Client.new(options)
```
