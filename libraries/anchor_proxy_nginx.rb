module AnchorCookbook
  class AnchorProxyNginx < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_proxy_nginx

    property :hostname, String, name_property: true, desired_state: false
    property :ssl, [TrueClass, FalseClass], default: false, desired_state: false

    default_action :enable

    action :enable do
      include_recipe 'nginx'

      template '/etc/nginx/sites-available/anchor' do
        source 'nginx/anchor.erb'
        owner 'root'
        group 'root'
        mode 0644
        variables(
          ssl: new_resource.ssl,
          hostname: new_resource.hostname
        )
        cookbook 'anchor'
        action :create
        notifies :reload, 'service[nginx]'
      end

      nginx_site 'default' do
        enable false
        notifies :reload, 'service[nginx]'
      end

      nginx_site 'anchor' do
        notifies :reload, 'service[nginx]'
      end
    end

    action :disable do
      nginx_site 'anchor' do
        enable false
        notifies :reload, 'service[nginx]'
      end
    end
  end
end
