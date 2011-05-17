require 'spec_helper'

describe LocomotiveExporter::Task::AssetCollections do

  before :each do
    @site = Factory(:site)
    @asset_collection = Factory(:asset_collection, :site => @site)
    @database = { 'site' => {} }
    @theme_path = Rails.root.join('tmp', 'themes', @site.id.to_s)
    @context = {
      :site       => @site,
      :database   => @database,
      :theme_path => @theme_path,
      :error      => nil,
      :worker     => @worker
    }
    @options = {}
  end

  context 'standard asset collection hash' do

    it 'should define an asset collections hash' do
      LocomotiveExporter::Task::AssetCollections.process(@context,@options)

      @context[:database]['site']['asset_collections'].should_not be_empty
    end

    it 'should define a specific asset collection hash' do
      LocomotiveExporter::Task::AssetCollections.process(@context,@options)

      @context[:database]['site']['asset_collections'][@asset_collection.name].should_not be_empty
    end

    it 'should define the following asset_collection default attributes' do
      LocomotiveExporter::Task::AssetCollections.process(@context,@options)

      %w(slug).each do |method|
        @context[:database]['site']['asset_collections'][@asset_collection.name][method].should == @asset_collection.send(method)
      end
    end

  end

  context 'asset collection custom fields hash' do

    it 'should define a fields hash in each asset collection' do
      LocomotiveExporter::Task::AssetCollections.process(@context,@options)

      @context[:database]['site']['asset_collections'][@asset_collection.name]['fields'].should_not be_empty
    end

    it 'should assign the each field within the hash' do
      LocomotiveExporter::Task::AssetCollections.process(@context,@options)

      @asset_collection.asset_custom_fields.each do |field|
        @context[:database]['site']['asset_collections'][@asset_collection.name]['fields'][@asset_collection.send(field.label)].should_not be_empty
      end
    end

  end

    # context 'content instances' do

    #   before :each do
    #     @content = @content_type.contents.create(:email => "email@test.com")
    #   end

    #   it 'should return a hash of the content instances' do
    #     LocomotiveExporter::Task::ContentTypes.process(@context,@options)

    #     @context[:database]['site']['content_types'][@content_type.name]['contents'].should be_an_instance_of(Array)
    #     @context[:database]['site']['content_types'][@content_type.name]['contents'][0].should be_an_instance_of(Hash)
    #   end

    #   it 'should have a hash for each content_type name by their slug' do
    #     field = @content_type.content_custom_fields.first
    #     LocomotiveExporter::Task::ContentTypes.process(@context,@options)

    #     @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize].should be_an_instance_of(Hash)
    #   end

    #   context 'content attributes' do

    #     it 'should output the attributes of the content' do
    #       field = @content_type.content_custom_fields.first
    #       LocomotiveExporter::Task::ContentTypes.process(@context,@options)

    #       @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize]['email'].should == @content.email
    #     end

    #   end

    # end

    # context 'content assets' do

    #   it 'should create content assets' do
    #     FileUtils.mkdir_p("#{Rails.root}/public/sites/test")
    #     FileUtils.cp("#{Rails.root}/spec/fixtures/assets/5k.png","#{Rails.root}/public/sites/test/5k.png")

    #     @template = File.join(Rails.root,'tmp','themes',@site.id.to_s,"public","samples",@content_type.name,"5k.png")

    #     File.exists?(@template).should be_false

    #     @content = ContentInstance.new
    #     @content.stubs(:_slug).returns("some_content")
    #     @content.stubs(:aliased_attributes).returns({ "email" => "email@email.com", "photo" => "/sites/test/5k.png"})
    #     ContentType.any_instance.stubs(:contents).returns([@content])
    #     LocomotiveExporter::Task::ContentTypes.process(@context,@options)

    #     File.exists?(@template).should be_true
    #     File.readable?(@template).should be_true
    #     File.size?(@template).should be_true

    #     FileUtils.rm_rf("#{Rails.root}/public/sites/test")
    #   end

    # end

end
