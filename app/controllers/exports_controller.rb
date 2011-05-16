module Admin
  class ExportsController < BaseController

    def new
      begin
        export = Locomotive::Export::Job.run!(current_site)      
        #send_file File.expand_path(export), :filename => "#{current_site.name}.zip", :filetype => "application/zip"
        redirect_to "http://#{Locomotive.config.default_domain}/#{export}"
      rescue Exception => e
        render :text=>"Failed"
        logger.error e
        logger.error e.backtrace
      end
    end
  end
end