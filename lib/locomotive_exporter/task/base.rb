module LocomotiveExporter
  module Task
    require 'fileutils'

    class Base

      include LocomotiveExporter::Logger

      attr_reader :site, :options

      def initialize(context, options)
        @context = context
        @options = options
        self.log "*** starting to process ***"
      end

      def self.process(site, options)
        new(site,options).process
      end

      def process
        raise 'this method has to be overidden'
      end

      protected

      def site
        @context[:site]
      end

      def database
        @context[:database]['site']
      end

      def theme_path
        @context[:theme_path]
      end

      def site_url
        @options[:site_url]
      end

      def download_file(url, dir)
        # no longer reference ThemeAssetUploader as there appears to be runtime issues referring to it.
        whitelisted_extensions = %w(jpg jpeg gif png css js swf flv eot svg ttf woff otf ico)
        if url.scan(/^(http[s]?:\/\/)/).present?
          if whitelisted_extensions.include?(File.extname(url).gsub(".",""))
            uri = URI.parse(url)
            open(uri) do |source|
              directory = FileUtils.mkdir_p(theme_path.join('public',*dir))
              File.open(File.join(directory, File.basename(url)),'wb') do |result|
                result.write(source.read)
              end
            end
          else
            ::Locomotive::Logger.info "\t [Locomotive Exporter: File `#{url}` was not a valid export]"
          end
        end
      end

      def copy_file_from_theme(path, dir)
        directory = FileUtils.mkdir_p(theme_path.join('public',*dir))
        File.cp(path, File.join(directory, File.basename(path)))
      end

    end
  end
end
