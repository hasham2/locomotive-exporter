module Locomotive
  module Export
    class Job
      
      include Logger
      
      def initialize(site, options = {})
        @site = site
        @options = {
           :files    => true,
           :enabled  => {},
         }.merge(options)
      end
      
      def before(worker)
        @worker = worker
      end
      
      def perform
        create_working_folder
        create_database_hash
        
        context = {
          :database   => @database,
          :site       => @site,
          :theme_path => @theme_path,
          :error      => nil,
          :worker     => @worker
        }
        
        %w(site pages content_types snippets assets asset_collections).each do |step|
          # Export These
          if @options[:enabled][step] != false
            self.log("*** Actioning: #{step} ***")
            "Locomotive::Export::#{step.camelize}".constantize.process(context, @options)
          else
            self.log "skipping #{step}"
          end
        end
        
        create_database_yaml
        create_zip
        remove_working_folder
        copy_zip_to_public
        @zip
      end
        
      def self.run!(site, options = {})
        job = self.new(site, options)

        if Locomotive.config.delayed_job
          Delayed::Job.enqueue job, { :site => site, :job_type => 'export' }
        else
          job.perform
        end
      end
      
      protected

      def themes_folder
        return @theme_path if defined?(@theme_path)
        @theme_path = File.join(Rails.root, 'tmp', 'themes', site_name)
      end
      
      def site_name
        @site.name.downcase.gsub(" ", "_").to_s
      end
      
      def create_working_folder
        remove_working_folder
        remove_zip
        
        FileUtils.mkdir_p(File.join(themes_folder,'public','samples'))
        FileUtils.mkdir_p(File.join(themes_folder,'snippets'))
        FileUtils.mkdir_p(File.join(themes_folder,'templates'))
      end

      def create_zip
        `cd #{File.join("tmp","themes")}; zip -r #{site_name}.zip #{site_name}`
        @zip = File.join(themes_folder,'..',"#{site_name}.zip")
      end

      def copy_zip_to_public
        `cp #{Rails.root.join("tmp","themes",site_name)}.zip #{Rails.root.join('public')}`
        @zip = "#{site_name}.zip"
      end
      
      def create_database_hash
        @database = { 'site' => {} }
      end
      
      def create_database_yaml
        @file = File.open(File.join(themes_folder, 'database.yml'), 'w+') { |f|
          YAML.dump(@database, f)
        }
      end
      
      def remove_working_folder
        FileUtils.rm_rf themes_folder if File.exists?(themes_folder)
      end
      
      def remove_zip
        FileUtils.rm_rf File.join(themes_folder, '..', "#{site_name}.zip") if File.exists?(File.join(themes_folder, '..', "#{site_name}.zip"))
      end
      
    end
  end
end