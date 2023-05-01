module MistralClient
  module Mixins
    module MistralObject
      def self.included(child)
        child.send(:attr_reader, :id)

        %w[UNICODE_FIELDS DATE_FIELDS JSON_FIELDS BOOL_FIELDS].each do |fields|
          next unless child.const_defined? fields

          child.send(:attr_reader, *child.const_get(fields))
        end
      end

      def reload(id = @id)
        resp = @server.get("#{self.class::PATH}/#{id}")
        ivars_from_response(resp)
        self
      end

      def list(**params)
        resp = @server.get("#{self.class::PATH}?#{URI.encode_www_form(params)}")
        resp[self.class::PATH].map do |t|
          task = self.class.new(@server)
          task.ivars_from_response(t)
          task
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/PerceivedComplexity
      def ivars_from_response(resp)
        klass = self.class
        @id = resp['id']
        klass::UNICODE_FIELDS.each do |var|
          instance_variable_set("@#{var}", resp[var]) if resp[var]
        end
        klass::BOOL_FIELDS.each do |var|
          instance_variable_set("@#{var}", resp[var]) if resp.key? var
        end
        klass::DATE_FIELDS.each do |var|
          instance_variable_set("@#{var}", DateTime.parse(resp[var])) if resp[var]
        end
        klass::JSON_FIELDS.each do |var|
          instance_variable_set("@#{var}", JSON.parse(resp[var])) if resp[var]
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize
    end
  end
end
