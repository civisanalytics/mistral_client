module MistralClient
  module Mixins
    module Deletable
      def delete!
        resp = @server.delete("#{self.class::PATH}/#{id}")
        return true if resp.code == 204

        raise MistralClient::MistralError,
              "Could not perform the requested operation:\n#{resp.body}"
      end
    end
  end
end
