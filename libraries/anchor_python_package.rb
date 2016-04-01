module AnchorCookbook
  class AnchorPythonPackage < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_python_package

    property :package_name, String, name_property: true
    property :version, String, desired_state: true

    default_action :install

    action :install do
      python_package new_resource.package_name do
        version new_resource.version
        user node["anchor"]["username"]
        group node["anchor"]["groupname"]
        virtualenv node["anchor"]["venv_path"]
        action :install
      end
    end

    action :upgrade do
      python_package new_resource.package_name do
        version new_resource.version
        user node["anchor"]["username"]
        group node["anchor"]["groupname"]
        virtualenv node["anchor"]["venv_path"]
        action :upgrade
      end
    end

    action :remove do
      python_package new_resource.package_name do
        virtualenv node["anchor"]["venv_path"]
        action :remove
      end
    end
  end
end
