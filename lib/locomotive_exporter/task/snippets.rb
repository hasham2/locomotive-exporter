module LocomotiveExporter
  module Task
    class Snippets < Base

      def process
        @hash = { 'snippets' => {} }

        site.snippets.each do |snippet|
          @snippet = snippet
          export_template
        end

        database.merge!(@hash)
      end

      protected

      # Template
      def export_template
        FileUtils.mkdir_p(File.dirname(File.join(theme_path,'snippets',@snippet.slug)))

        File.open(File.join(theme_path,'snippets',%{#{@snippet.slug}.liquid}),'w+') { |f|
          f << @snippet.template
        }
      end

    end
  end
end
