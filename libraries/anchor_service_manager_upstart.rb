module AnchorCookbook
  class AnchorServiceManagerUpstart < AnchorServiceBase
    use_automatic_resource_name

    provides :anchor_service, platform: 'ubuntu'

    action :start do
      package 'uwsgi-plugin-python'

      template '/etc/init/anchor.conf' do
        source 'upstart/anchor.conf.erb'
        owner 'root'
        group 'root'
        mode '0644'
        cookbook 'anchor'
        variables(
          anchor_python_home: '/opt/anchor/current',
          anchor_virtualenv: '/opt/anchor/.venv',
          anchor_user: 'anchor',
          anchor_group: 'anchor'
        )
        action :create
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
