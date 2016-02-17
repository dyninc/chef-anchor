require 'json'

include_recipe 'chef-vault'

anchor_installation_git '/opt/anchor' do
  repourl 'git://git.openstack.org/openstack/anchor'
end

anchorconf = data_bag_item('anchor', 'config')
anchorcerts = chef_vault_item('anchor', 'ca')

file "/opt/anchor/shared/config.json" do
  owner 'anchor'
  group 'anchor'
  mode '0644'
  content JSON.pretty_generate(anchorconf.raw_data)
  action :create
  notifies :restart, 'anchor_service[anchor]'
end

anchor_ca 'myca' do
  path '/opt/anchor/shared/CA'
  certificate anchorcerts['certificate']
  key anchorcerts['key']
end

anchor_service 'anchor' do
  action :start
end

anchor_proxy_nginx 'localhost' do
  ssl false
end
