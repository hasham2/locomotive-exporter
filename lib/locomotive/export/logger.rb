module Locomotive
  module Export
    module Logger
      
      def log(message, domain = '')
        puts message
        head = "[export_theme]"
        head += "[#{domain}]" unless domain.blank?
        ::Locomotive::Logger.info "\t#{head} #{message}"
      end
      
    end
  end
end