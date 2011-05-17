module LocomotiveExporter
  module Task
    class ContentTypes < Base

      def process
        @hash = { 'content_types' => {} }

        site.content_types.each do |content_type|
          @content_type = content_type
          data_hash
        end

        database.merge!(@hash)
      end

      protected

      def data_hash
        @hash['content_types'].merge!(content_type_hash)
      end

      # YAML
      def content_type_hash
        attributes = @content_type.attributes.to_hash

        # Standard Attributes
        attributes.reject!{ |k,_| !%w(slug name description api_enabled).include?(k) }

        # Custom Attributes
        attributes.merge!({
          'order_by'               => content_type_order_by_field,
          'highlighted_field_name' => content_type_highlighted_field
        })

        # Custom Fields
        attributes.merge!({ 'fields' => content_type_fields_hash })
        attributes.merge!({ 'contents' => content_instances_hash })

        attributes.reject!{ |k,v| v.nil? }
        { @content_type.name => attributes.to_hash }
      end

      def content_type_fields_hash
        attributes = []

        @content_type.content_custom_fields.each do |field|
          attributes << { field._alias => field.attributes.to_hash.reject{ |k,v| !%w(slug label kind hint).include?(k) || v.blank? } }
        end

        attributes
      end

      def content_instances_hash
        attributes = []

        @content_type.contents.each do |content|
          attrs = {}
          content.custom_fields.each do |field|
            if field.kind == 'file'
              # Copy file self.send(field._name.to_sym).path
              file = content.send(field._name.to_sym)
              path = %{samples/#{@content_type.name}/#{File.basename(file.path)}}
              copy_file_from_theme file.path, [ 'samples', @content_type.name ]

              attrs[field._alias] = "/#{path}"
            else
              attrs[field._alias] = content.send(field._name.to_sym)
            end
          end
          attributes << { content._slug.humanize => attrs }
        end

        attributes
      end

      def content_type_order_by_field
        if field = @content_type.content_custom_fields.where(:_name => @content_type.order_by).first
          field._alias
        elsif @content_type.order_by.present?
          @content_type.order_by == "_position_in_list" ? nil : @content_type.order_by
        else
          'created_at'
        end
      end

      def content_type_highlighted_field
        @content_type.highlighted_field._alias
      end

    end
  end
end
