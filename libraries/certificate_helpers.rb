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
        request.sign(key, OpenSSL::Digest::SHA256.new)

        request
      end

      def submit_csr (request, anchor={})
        # Send the CSR to Anchor
        result = Net::HTTP.post_form(
          URI.parse(anchor[:url]),
          {
            user: anchor[:user],
            secret: anchor[:secret],
            encoding: 'PEM',
            csr: request.to_pem
          }
        ).body

        # Try to create a certificate from the result
        # to confirm its valid otherwise fail
        begin
          OpenSSL::X509::Certificate.new(result)
        rescue
          Chef::Application.fatal! "Generating the SSL certificate for #{request.cn} failed, unable to proceed"
        end
        result
      end
    end
  end
end
