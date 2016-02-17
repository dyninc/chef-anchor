module AnchorCookbook
  require_relative 'anchor_service_base.rb'
  class AnchorService < AnchorServiceBase
    use_automatic_resource_name

    provides :anchor_service

    property :service_manager, %w(upstart), default: 'upstart', desired_state: false
  end
end
