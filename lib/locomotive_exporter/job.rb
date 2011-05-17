module LocomotiveExporter
  class Job

    require 'locomotive_exporter/task/base'
    require 'locomotive_exporter/task/site'
    require 'locomotive_exporter/task/pages'
    require 'locomotive_exporter/task/content_types'
    require 'locomotive_exporter/task/snippets'
    require 'locomotive_exporter/task/theme_assets'
    require 'locomotive_exporter/task/asset_collections'

    include LocomotiveExporter::Logger

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

      context = {
        :database   => database,
        :site       => @site,
        :theme_path => theme_path,
        :error      => nil,
        :worker     => @worker
      }

      %w(site pages content_types snippets theme_assets asset_collections).each do |step|
        # Exporter These
        if @options[:enabled][step] != false
          self.log("*** Actioning: #{step} ***")
          "LocomotiveExporter::Task::#{step.camelize}".constantize.process(context, @options)
        else
          self.log "skipping #{step}"
        end
      end

      create_database_yaml
      create_zip
      remove_working_folder
    end

    def self.run!(site, options = {})
      job = self.new(site, options)
      job.perform

      job
    end

    def exported_theme
      "#{theme_path}.zip"
    end

    protected

    def theme_path
      Rails.root.join('tmp', 'themes', site_name)
    end

    def site_name
      @site.name.downcase.gsub(" ", "_").to_s
    end

    def create_working_folder
      remove_working_folder
      remove_zip

      FileUtils.mkdir_p theme_path.join('public','samples')
      FileUtils.mkdir_p theme_path.join('snippets')
      FileUtils.mkdir_p theme_path.join('templates')
    end

    def create_zip
      method = "cd #{theme_path.join('../')} && zip -r #{File.basename(exported_theme)} #{File.basename(theme_path)} 2>&1"
      result = `#{method}`
      unless $?.exitstatus == 0
        raise StandardError.new("#{method}\n\n#{result}")
      end
    end

    def database
      @database ||= { 'site' => {} }
    end

    def create_database_yaml
      @file = File.open(theme_path.join('database.yml'), 'w+') { |f|
        YAML.dump(database, f)
      }
    end

    def remove_working_folder
      FileUtils.rm_rf theme_path if File.exists?(theme_path)
    end

    def remove_zip
      FileUtils.rm_rf exported_theme if File.exists?(exported_theme)
    end

  end
end
