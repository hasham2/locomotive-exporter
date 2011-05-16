require 'spec_helper'

describe Locomotive::Exporter::Job do
  
  before :each do
    @site = Factory(:site)
    @site_name = @site.name.downcase.gsub(" ", "_")
    @theme_path = File.join(Rails.root,'tmp','themes',@site_name)
    @options = {
      :theme_path => @theme_path,
      :error      => nil,
      :worker     => @worker,
      :site_url   => "http://example.com"
    }
  end
  
  describe 'database' do
    before :each do
      # Don't destroy working directory
      Locomotive::Exporter::Job.any_instance.stubs(:remove_working_folder).returns(true)
    end
    it 'should create the database.yml file' do
      @database = File.join(Rails.root,'tmp','themes',@site_name,'database.yml')
      
      File.exists?(@database).should be_false
      
      Locomotive::Exporter::Job.run!(@site,@options)
      
      File.exists?(@database).should be_true
      File.readable?(@database).should be_true
      File.size?(@database).should be_true
    end
  end
  
  describe 'templates' do
    before :each do
      # Don't destroy working directory
      Locomotive::Exporter::Job.any_instance.stubs(:remove_working_folder).returns(true)
      
      @directory = File.join(Rails.root,'tmp','themes',@site_name,'templates')
      File.exists?(@directory).should be_false
      Locomotive::Exporter::Job.run!(@site,@options)
    end
    it 'should create the directory' do
      File.exists?(@directory).should be_true
      File.directory?(@directory).should be_true
      File.readable?(@directory).should be_true
    end
    it 'should not be an empty directory' do
      Dir[@directory].empty?.should be_false
    end
  end
  
  describe 'zip' do
    before :each do
      @zip = File.join(Rails.root,'tmp','themes',"#{@site_name}.zip")
      Locomotive::Exporter::Job.run!(@site,@options)
    end
    it 'should create the zip' do
      File.exists?(@zip).should be_true
      File.readable?(@zip).should be_true
    end
  end
  
  after :each do
    FileUtils.rm_r(File.join(Rails.root,'tmp','themes'),:force => true)
  end
  
end
