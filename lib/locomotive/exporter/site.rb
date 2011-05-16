module Locomotive
  module Exporter
    class Site < Base
      
      def process
        database.merge!(data_hash)
      end
      
      protected
      
      def data_hash
        attributes = site.attributes
        attributes.reject!{ |k,_| !allowed_attributes.include?(k) }
        attributes.to_hash
      end
      
      def allowed_attributes
        %w{name locale meta_keywords meta_description} # domains
      end
      
    end
  end
end
