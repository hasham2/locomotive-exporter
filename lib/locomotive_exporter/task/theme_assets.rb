module LocomotiveExporter
  module Task
    class ThemeAssets < Base

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
            copy_file_from_theme asset.source.path, asset.folder
          end

          File.unlink(buffer) if File.exists?(buffer)
        end
      end

    end
  end
end
