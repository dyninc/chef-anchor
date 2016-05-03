module AnchorCookbook
  class AnchorInstallationPip < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_installation

    property :username, String, default: 'anchor'
    property :groupname, String, default: 'anchor'
    property :version, String, default: 'latest'
    property :deploy_to, String, name_property: true

    default_action :create

    def dependencies
      ['build-essential', 'python-dev', 'libffi-dev', 'libssl-dev']
    end

    action :create do
      python_runtime '3'

      dependencies.each do |pkg|
        package pkg
      end

      group new_resource.groupname

      user new_resource.username do
        group new_resource.groupname
        shell '/bin/false'
        home new_resource.deploy_to
      end

      # Used in anchor_python_package to set correct user/group
      node.default['anchor']['username'] = new_resource.username
      node.default['anchor']['groupname'] = new_resource.groupname

      directory new_resource.deploy_to do
        owner new_resource.username
        group new_resource.groupname
        mode 0755
        action :create
      end

      directory "#{new_resource.deploy_to}/certs" do
        owner new_resource.username
        group new_resource.groupname
        mode 0700
        action :create
      end

      python_virtualenv new_resource.deploy_to do
        user new_resource.username
        group new_resource.groupname
        pip_version true
        notifies :run, 'execute[chown-venv]', :immediately
      end

      # Work around for https://github.com/poise/poise-python/issues/42
      execute 'chown-venv' do
        command "chown -R #{new_resource.username}:#{new_resource.groupname} " \
                "#{new_resource.deploy_to}/lib"
        user 'root'
        action :nothing
      end

      # Used in anchor_python_package to set correct venv path
      node.default['anchor']['venv_path'] = new_resource.deploy_to
      node.default['anchor']['python_path'] = "#{new_resource.deploy_to}/bin/python"

      python_package 'anchor' do
        virtualenv new_resource.deploy_to
        user new_resource.username
        group new_resource.groupname
      end
    end

    action :delete do
      directory new_resource.deploy_to do
        recursive true
        action :delete
      end
    end
  end
end
