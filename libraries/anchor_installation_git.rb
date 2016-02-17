module AnchorCookbook
  class AnchorInstallationGit < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_installation

    property :repourl, String, desired_state: false
    property :username, String, default: 'anchor'
    property :groupname, String, default: 'anchor'
    property :deploy_to, String, name_property: true

    default_action :create

    def default_git_url
      'git://git.openstack.org/openstack/anchor'
    end

    def dependencies
      ['build-essential', 'python-dev', 'libffi-dev', 'libssl-dev']
    end

    action :create do
      python_runtime '2'
      package 'git'

      dependencies.each do |pkg|
        package pkg
      end

      group new_resource.groupname

      user new_resource.username do
        group new_resource.groupname
        shell '/bin/false'
        home new_resource.deploy_to
      end

      url = new_resource.repourl || default_git_url

      deploy 'anchor' do
        repo url
        user new_resource.username
        deploy_to new_resource.deploy_to
        symlink_before_migrate({})
        purge_before_symlink [ 'CA', 'config.json' ]
        symlinks 'CA' => 'CA', 'config.json' => 'config.json'
        migrate false
        action :deploy
      end

      python_virtualenv "#{new_resource.deploy_to}/.venv" do
        user new_resource.username
        group new_resource.groupname
      end

      pip_requirements "#{new_resource.deploy_to}/current/" do
        user new_resource.username
        group new_resource.groupname
        virtualenv "#{new_resource.deploy_to}/.venv"
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
