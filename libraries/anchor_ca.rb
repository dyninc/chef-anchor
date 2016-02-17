module AnchorCookbook
  class AnchorCA < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_ca

    property :path, String, name_property: true
    property :certificate, String, required: true
    property :key, String, required: true
    property :owner, String, default: 'anchor'
    property :group, String, default: 'anchor'

    default_action :create

    action :create do
      directory new_resource.path do
        owner new_resource.owner
        group new_resource.group
        mode 0700
        action :create
      end

      file "#{new_resource.path}/root-ca.crt" do
        owner new_resource.owner
        group new_resource.group
        mode 0400
        content new_resource.certificate
        sensitive true
        action :create
      end

      file "#{new_resource.path}/root-ca-unwrapped.key" do
        owner new_resource.owner
        group new_resource.group
        mode 0400
        content new_resource.key
        sensitive true
        action :create
      end
    end

    action :delete do
      directory new_resource.path do
        recursive true
        action :remove
      end
    end
  end
end
