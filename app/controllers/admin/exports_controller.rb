module Admin
  class ExportsController < BaseController

    def new
      @job = Locomotive::Exporter::Job.run!(current_site)
      send_file @job.exported_theme, :filename => "#{current_site.name}.zip", :filetype => "application/zip"
    end
  end
end
