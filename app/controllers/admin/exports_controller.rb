module Admin
  class ExportsController < BaseController

    def new
      begin
        export = Locomotive::Exporter::Job.run!(current_site)
        send_file File.expand_path(export), :filename => "#{current_site.name}.zip", :filetype => "application/zip"
      rescue Exception => e
        logger.error e
        logger.error e.backtrace
        flash[:alert] = 'Unable to export site'
        redirect_to '/admin'
      end
    end
  end
end
