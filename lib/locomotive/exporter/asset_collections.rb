module Locomotive
  module Exporter
    class AssetCollections < Base
      def process
        @hash = { 'asset_collections' => {} }

        site.asset_collections.each do |asset_collection|
          @asset_collection = asset_collection
          data_hash
        end

        database.merge!(@hash)
      end

      protected

      def data_hash
        @hash['asset_collections'].merge!(asset_collection_hash)
      end

      def asset_collection_hash
        return if ignored_collections.include?(@asset_collection.name)

        attributes = @asset_collection.attributes.to_hash

        attributes.reject!{ |attribute,_| !%w(slug).include?(attribute) }

        attributes.merge!({ 'fields' => asset_collection_fields_hash })
        attributes.merge!({ 'assets' => asset_collection_assets_hash })

        { @asset_collection.name => attributes.to_hash } 
      end

      def asset_collection_fields_hash
        attributes = {}

        @asset_collection.asset_custom_fields.collect do |field|
          attributes.merge!(field.label => {"kind"=>field.kind})
        end

        attributes
      end

      def asset_collection_assets_hash
        file_collection_name = @asset_collection.name.gsub("-"," ").parameterize("_")
        folder = Rails.root.join('tmp', 'themes', (site.name.downcase.gsub(" ", "_").to_s), "public", "assets", file_collection_name)
        FileUtils.mkdir_p(folder)
        assets = @asset_collection.assets.collect do |asset|
          FileUtils.cp asset.source.path, folder
          name = asset.name
          source_filename = asset.source_filename
          url = "/assets/#{file_collection_name}/#{source_filename}"
          ret = {}
          ret[name] = {"url"=>url}
          ret
        end        
      end

      def ignored_collections
        [ 'system' ]
      end
    end
  end
end

