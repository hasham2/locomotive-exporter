module LocomotiveExporter
  module Task

    class AssetCollections < Base

      # Processes all of the asset collections for the current site
      # Inserts the output into the database store
      # The output of the processing is formatted like so:
      #
      # asset_collections:
      #   "Feature Sections":
      #     slug: features
      #     fields:
      #       - slug:
      #           kind: string
      #       - description:
      #           kind: string
      #     assets:
      #       - "Switchrooms":
      #           slug: "switchrooms"
      #           url: "/samples/banner-switchrooms.jpg"
      #           description: "Lorem ipsum dolor sit amet"
      #       - "Air Conditioning":
      #           slug: "air_conditioning"
      #           url: "/samples/banner-aircon.jpg"
      #           description: "Lorem ipsum dolor sit amet"
      #       - "Fire Services":
      #           slug: "fire_services"
      #           url: "/samples/banner-fire.jpg"
      #           description: "Lorem ipsum dolor sit amet"

      def process
        asset_collections = {}
        site.asset_collections.each do |asset_collection|
          unless ignored_collections.include?(asset_collection.name)
            asset_collections[asset_collection.name] = asset_collection_attributes(asset_collection) 
          end
        end

        database['asset_collections'] = asset_collections
      end

      protected

      def asset_collection_attributes(asset_collection)
        { "fields" => collect_fields(asset_collection),
          "assets" => collect_assets(asset_collection),
          "slug" => asset_collection.slug }
      end

      def collect_fields(asset_collection)
        asset_collection.asset_custom_fields.map do |field|
          { field.label => { "kind" => field.kind } }
        end
      end

      def collect_assets(asset_collection)
        file_collection_name = asset_collection.name.gsub("-"," ").parameterize("_")
        folder = theme_path.join("public", "assets", file_collection_name)
        FileUtils.mkdir_p(folder)

        asset_collection.assets.map do |asset|
          FileUtils.cp asset.source.path, folder
          source_filename = asset.source_filename

          { asset.name => { "url" => "/assets/#{file_collection_name}/#{source_filename}" } }
        end
      end

      def ignored_collections
        [ 'system' ]
      end

    end

  end
end
