module Locomotive
  module Export
    require 'fileutils'

    class Base
      
      include Logger
      
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
      
      def log(message)
        super(message,self.class.name.demodulize.underscore)
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
      
      def download_file(url,dir)
        # no longer reference ThemeAssetUploader as there appears to be runtime issues referring to it.
        whitelisted_extensions = %w(jpg jpeg gif png css js swf flv eot svg ttf woff otf ico)
        if url.scan(/^(http[s]?:\/\/)/).present?
          if whitelisted_extensions.include?(File.extname(url).gsub(".",""))
            uri = URI.parse(url)
            open(uri) do |source|
              directory = FileUtils.mkdir_p(File.join(theme_path,'public',*dir))
              File.open(File.join(directory,File.basename(url)),'wb') do |result|
                result.write(source.read)
              end 
            end
          else
            ::Locomotive::Logger.info "\t [Locomotive Export: File `#{url}` was not a valid export]"
          end
        else
          directory = FileUtils.mkdir_p(File.join(theme_path,'public',*dir))
          File.cp(File.join(Rails.root,'public',url),File.join(directory,File.basename(url)))
        end
      end
      
    end
  end
end