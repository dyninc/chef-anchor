require 'net/https'
require 'uri'

module AnchorCookbook
  module AnchorHelpers
    module Certificate
      def generate_subject(new_resource)
        OpenSSL::X509::Name.new([
          ['C', new_resource.country, OpenSSL::ASN1::PRINTABLESTRING],
          ['ST', new_resource.state, OpenSSL::ASN1::PRINTABLESTRING],
          ['L', new_resource.city, OpenSSL::ASN1::PRINTABLESTRING],
          ['O', new_resource.organisation, OpenSSL::ASN1::UTF8STRING],
          ['OU', new_resource.department, OpenSSL::ASN1::UTF8STRING],
          ['CN', new_resource.cn, OpenSSL::ASN1::UTF8STRING],
          ['emailAddress', new_resource.email, OpenSSL::ASN1::UTF8STRING]
        ])
      end

      def generate_csr(new_resource, key)
        # Create a new CSR
        request = OpenSSL::X509::Request.new
        request.version = 0
        request.subject = generate_subject(new_resource)
        request.public_key = key.public_key

        ef = OpenSSL::X509::ExtensionFactory.new
        extensions = []
        new_resource.extensions.each_pair do |oid, value|
          extensions.push ef.create_extension(oid, value)
        end

        attrval = OpenSSL::ASN1::Set([OpenSSL::ASN1::Sequence(extensions)])
        request.add_attribute(OpenSSL::X509::Attribute.new('extReq', attrval))

        request.sign(key, OpenSSL::Digest::SHA256.new)
        request
      end

      # rubocop:disable MethodLength
      def submit_csr(request, anchor = {})
        # Send the CSR to Anchor
        uri = URI.parse(anchor[:url])
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless anchor[:verifyssl]
        end
        params = {
          user: anchor[:user],
          secret: anchor[:secret],
          encoding: 'PEM',
          csr: request.to_pem
        }
        req = Net::HTTP::Post.new(uri.request_uri)
        req.set_form_data(params)
        result = http.request(req).body

        # Try to create a certificate from the result
        # to confirm its valid otherwise fail
        begin
          OpenSSL::X509::Certificate.new(result)
        rescue
          Chef::Log.error 'Response from Anchor was not a valid certificate'
          Chef::Log.error result
          Chef::Application.fatal! 'Unable to proceed due to invalid response'
        end
        result
      end
    end
  end
end
