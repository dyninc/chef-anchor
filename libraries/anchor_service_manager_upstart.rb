module AnchorCookbook
  class AnchorServiceManagerUpstart < AnchorServiceBase
    use_automatic_resource_name

    provides :anchor_service, platform: 'ubuntu'

    property :anchor_home, String, default: '/opt/anchor/current'
    property :anchor_venv, String, default: '/opt/anchor/.venv'
    property :username, String, default: 'anchor'
    property :groupname, String, default: 'anchor'

    action :start do
      package 'uwsgi-plugin-python3'

      template '/etc/init/anchor.conf' do
        source 'upstart/anchor.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        cookbook 'anchor'
        variables(
          anchor_python_home: new_resource.anchor_home,
          anchor_virtualenv: new_resource.anchor_venv,
          anchor_user: new_resource.username,
          anchor_group: new_resource.groupname
        )
        action :create
        notifies :restart, 'service[anchor]'
      end

      service 'anchor' do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :start
      end
    end

    action :stop do
      service 'anchor' do
        provider Chef::Provider::Service::Upstart
        supports status: true
        action :stop
      end
    end

    action :restart do
      action_stop
      action_start
    end
  end
end
