module LocomotiveExporter
  module Logger

    require 'locomotive/logger'

    def log(message, domain = '')
      puts message
      head = "[export_theme]"
      head += "[#{domain}]" unless domain.blank?
      ::Locomotive::Logger.info "\t#{head} #{message}"
    end

  end
end
