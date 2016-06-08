module AnchorCookbook
  class AnchorCertificate < ChefCompat::Resource
    require 'openssl'
    require 'uri'
    require 'net/http'
    require_relative 'certificate_helpers'

    include AnchorCookbook::AnchorHelpers::Certificate

    use_automatic_resource_name

    provides :anchor_certificate

    ################
    ## Properties ##
    ################
    property :cn, String, name_property: true
    property :country, String, required: true
    property :state, String, required: true
    property :city, String, default: ''
    property :organisation, String, default: ''
    property :department, String, default: ''
    property :email, String, default: ''
    property :extensions, Hash, default: {}

    # For my american colleagues
    alias_method :organization, :organisation

    # These map the friendly names above to the OpenSSL field names
    alias_method :C, :country
    alias_method :ST, :state
    alias_method :L, :city
    alias_method :O, :organisation
    alias_method :OU, :department
    alias_method :CN, :cn
    alias_method :emailAddress, :email

    # Size for the private key
    property :bits, Integer, default: 2048

    # URI & Credentials for talking to anchor
    property :anchorurl, String, required: true, desired_state: false
    property :anchoruser, String, required: true, desired_state: false
    property :anchorsecret, String, required: true, desired_state: false
    property :verifyssl, [TrueClass, FalseClass], default: true, desired_state: false

    # Where to place the certificate and key, owner, permissions etc.
    property :path, String, default: '', desired_state: false
    property :keyfile, String, default: 'key.pem'
    property :certfile, String, default: 'certificate.pem'
    property :owner, [String, Integer], default: 'root'
    property :group, [String, Integer], default: 'root'
    property :mode, [String, Integer], default: 0600

    #########################
    ## Load current value  ##
    #########################

    load_current_value do |new_resource|
      # Get paths
      keypath = ::File.join(new_resource.path, new_resource.keyfile)
      certpath = ::File.join(new_resource.path, new_resource.certfile)

      # Only if the certificate and key exist attempt to populate
      # the current_resource with the values
      if ::File.exist?(keypath) && ::File.exist?(certpath)
        begin
          certificate = OpenSSL::X509::Certificate.new IO.read(certpath)
          key = OpenSSL::PKey::RSA.new IO.read(keypath)

          # Check the key matches the certificate
          current_value_does_not_exist! unless certificate.check_private_key key

          # Load each field in the SSL certificate into the current_resource
          # for comparison
          certificate.subject.to_a.each { |field| send(field[0], field[1]) }
        rescue
          current_value_does_not_exist!
        end
      else
        Chef::Log.debug 'Certificate or Key file did not exist'
        current_value_does_not_exist!
      end
    end

    #############
    ## Actions ##
    #############

    action :create do
      # Initialise these here
      # Then try to load them in the converge_if_changed block
      key = nil
      certificate = nil

      keyfile = ::File.join(new_resource.path, new_resource.keyfile)
      certfile = ::File.join(new_resource.path, new_resource.certfile)

      converge_if_changed do
        # Key for the new certificate signing request
        key = OpenSSL::PKey::RSA.new new_resource.bits

        # Generate a new signing request
        request = generate_csr(new_resource, key)

        # Submit the CSR to anchor
        certificate = submit_csr(
          request,
          {
            url: new_resource.anchorurl,
            user: new_resource.anchoruser,
            secret: new_resource.anchorsecret,
            verifyssl: new_resource.verifyssl
          }
        )
      end

      file keyfile do
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        content key.to_pem unless key.nil?
        sensitive true
        action :create
      end

      file certfile do
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        content certificate unless certificate.nil?
        sensitive true
        action :create
      end
    end
  end
end
