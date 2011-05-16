module Locomotive
  module Exporter
    class Pages < Base

      def process
        @hash = { 'pages' => [] }

        site.all_pages_in_once.each do |page|
          process_page(page)
        end

        database.merge!(@hash)
      end

      protected

      def process_page(page)
        @page = Page.find(page.id)
        data_hash
        export_template
        @page.children.each do |page|
          process_page(page)
        end
      end
      
      def data_hash
        @hash['pages'] << page_hash
      end
      
      # YAML
      def page_hash
        attributes = @page.attributes.to_hash
        
        attributes.reject!{ |k,v| !%w(title published templatized listed cache_strategy redirect redirect_url).include?(k) }
        attributes['content_type'] = @page.content_type.slug if @page.templatized?
        
        { page_key => attributes }
      end
      
      # Template
      def export_template
        update_templates_editable_regions
        
        FileUtils.mkdir_p(File.dirname(File.join(theme_path, 'templates', page_key)))
        
        File.open(File.join(theme_path, 'templates', %{#{page_key}.liquid}), 'w+') { |f|
          f << @page.raw_template
        }
      end
      
      def update_templates_editable_regions
        update_templates_editable_texts
        update_templates_editable_files
      end
      
      def update_templates_editable_texts
        return nil if @page.raw_template.blank?
        template = @page.raw_template.gsub(/\{%\s*editable_(short_text|long_text)\s*'([^\']+)'[^\}]+%\}([^\{%]+)\{%[^\}]+%\}/) do |text|
          editable_area = @page.editable_elements.where(:slug => $2).first
          "{% editable_#{$1} '#{$2}' %}#{editable_area.content}{% endeditable_#{$1} %}"
        end
        @page.raw_template = template
      end
      
      def update_templates_editable_files
        return nil if @page.raw_template.blank?
        template = @page.raw_template.gsub(/\{%\s*editable_(file)\s*'([^\']+)'[^\}]+%\}([^\{%]+)\{%[^\}]+%\}/) do |text|
          editable_area = @page.editable_elements.where(:slug => $2).first
          if editable_area.content.present?
            download_file(editable_area.content,'samples')
          end
          
          "{% editable_#{$1} '#{$2}' %}/samples/#{File.basename(editable_area.content)}{% endeditable_#{$1} %}"
        end
        @page.raw_template = template
      end
      
      def page_key
        @page.fullpath.gsub("content_type_template","template")
      end
      
    end
  end
end
