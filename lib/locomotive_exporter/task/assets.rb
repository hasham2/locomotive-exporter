module LocomotiveExporter
  module Task
    class Assets < Base

      def process
        buffer = "tmp/export_buffer.txt"

        site.theme_assets.each do |asset|
          if asset.stylesheet?
            asset.plain_text.gsub!(/url\(("|')?(\/sites\/\w+\/theme)([^("|')?]+)("|')?\)/) do |text|
              "url(\"#{$3}\")"
            end
            directory = FileUtils.mkdir_p(File.join(theme_path,'public',*asset.folder))
            File.open(File.join(directory,File.basename(asset.source.url)),"wb") { |f| f << asset.plain_text }
          else
            download_file(asset.source.url,asset.folder)
          end

          File.unlink(buffer) if File.exists?(buffer)
        end
      end

    end
  end
end
