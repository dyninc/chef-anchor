require 'json'

include_recipe 'chef-vault'

anchor_installation_pip '/opt/anchor'

anchorconf = data_bag_item('anchor', 'config')
anchorcerts = chef_vault_item('anchor', 'ca')

file '/opt/anchor/config.json' do
  owner 'anchor'
  group 'anchor'
  mode '0644'
  content JSON.pretty_generate(anchorconf.raw_data)
  action :create
  notifies :restart, 'anchor_service[anchor]'
end

cookbook_file '/opt/anchor/config.py' do
  owner 'anchor'
  group 'anchor'
  action :create
  notifies :restart, 'anchor_service[anchor]'
end

anchor_ca 'myca' do
  path '/opt/anchor/CA'
  certificate anchorcerts['certificate']
  key anchorcerts['key']
end

anchor_service 'anchor' do
  anchor_home '/opt/anchor'
  anchor_venv '/opt/anchor'
  action :start
end

anchor_proxy_nginx 'localhost' do
  ssl false
  serve_certs true
end

anchor_certificate 'test.test.53151sa.net' do
  country 'UK'
  state 'S Gloucs'
  city 'Bristol'
  organisation 'Dyn'
  department 'Hivecast'
  email 'test@test.com'
  bits 2048
  path '/tmp'
  anchorurl 'http://localhost:5016/v1/sign/default'
  anchoruser 'myusername'
  anchorsecret 'simplepassword'
  verifyssl false
  action :create
end
