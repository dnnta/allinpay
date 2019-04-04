Allinpay.configuration do |config|
  config.merchant = '商户号'
  config.username =  '用户名: 商户号 + 02'
  cpnfig.password = '登录密码'
  config.env = '使用环境' # eg config.env = production
  config.private_path = '私钥文件' # eg config.private_path = '/lib/m.12'
  config.private_password = '私钥密码'
  config.public_path = '公钥文件' # eg config.public_path = '/lib/m.cer'
  config.platform = '自定义平台号'
end