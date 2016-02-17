module AnchorCookbook
  class AnchorServiceBase < ChefCompat::Resource
    use_automatic_resource_name

    provides :anchor_service_manager
  end
end

# Declare a module for subresoures' providers to sit in (backcompat)
class Chef
  class Provider
    module DockerServiceBase
    end
  end
end
