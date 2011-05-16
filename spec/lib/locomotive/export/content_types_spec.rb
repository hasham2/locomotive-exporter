require 'spec_helper'

describe Locomotive::Export::ContentTypes do
  
  before :each do
    @site = Factory(:site)
    @content_type = Factory(:content_type, :site => @site)
    @database = { 'site' => {} }
    @theme_path = %{#{Rails.root}/tmp/themes/#{@site.id.to_s}}
    @context = { 
      :site       => @site, 
      :database   => @database, 
      :theme_path => @theme_path, 
      :error      => nil, 
      :worker     => @worker 
    }
    @options = {}
  end
  
  context 'page database hash' do
    
    it 'should define a pages hash' do
      Locomotive::Export::ContentTypes.process(@context,@options)
      
      @context[:database]['site']['content_types'].should_not be_empty
    end
    
    it 'should define next pages hashes' do
      Locomotive::Export::ContentTypes.process(@context,@options)
      
      @context[:database]['site']['content_types'][@content_type.name].should_not be_empty
    end
    
    it 'should define the following content_type default attributes' do
      Locomotive::Export::ContentTypes.process(@context,@options)
      
      %w(slug name description api_enabled).each do |method|
        @context[:database]['site']['content_types'][@content_type.name][method].should == @content_type.send(method)
      end
    end
    
    context 'custom attributes' do
      
      context 'order_by' do
        
        it 'should use created_at if none is set' do
          @content_type.stubs(:order_by).returns(nil)
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should == 'created_at'
        end
        
        it 'should use the human name on a custom field' do
          @content_type.stubs(:order_by).returns('custom_field_1')
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should == 'email'
        end
        
        it 'should not send any order_by if set to _position_in_list' do
          @content_type.stubs(:order_by).returns('_position_in_list')
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should be_nil
        end
        
      end
      
      context 'highlighted_field_name' do
        
        it 'should use the human name' do
          field = @content_type.content_custom_fields.first
          @content_type.stubs(:highlighted_field).returns(field)
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['highlighted_field_name'].should == field._alias
        end
        
      end
      
    end
    
    context 'custom fields' do
      
      it 'should return a hash of custom fields' do
        Locomotive::Export::ContentTypes.process(@context,@options)
        
        @context[:database]['site']['content_types'][@content_type.name]['fields'].should be_an_instance_of(Array)
        @context[:database]['site']['content_types'][@content_type.name]['fields'][0].should be_an_instance_of(Hash)
      end
      
      it 'should have a hash for each content_type name by their label' do
        field = @content_type.content_custom_fields.first
        Locomotive::Export::ContentTypes.process(@context,@options)
        
        @context[:database]['site']['content_types'][@content_type.name]['fields'][0][field.label].should be_an_instance_of(Hash)
      end
      
      context 'field attributes' do
        
        it 'should output the attributes of the field' do
          field = @content_type.content_custom_fields.first
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['fields'][0][field.label]['label'].should == field.label
          @context[:database]['site']['content_types'][@content_type.name]['fields'][0][field.label]['kind'].should == field.kind
        end
        
      end
      
    end
    
    context 'content instances' do
      
      before :each do
        @content = @content_type.contents.create(:email => "email@test.com")
      end
      
      it 'should return a hash of the content instances' do
        Locomotive::Export::ContentTypes.process(@context,@options)
        
        @context[:database]['site']['content_types'][@content_type.name]['contents'].should be_an_instance_of(Array)
        @context[:database]['site']['content_types'][@content_type.name]['contents'][0].should be_an_instance_of(Hash)
      end
      
      it 'should have a hash for each content_type name by their slug' do
        field = @content_type.content_custom_fields.first
        Locomotive::Export::ContentTypes.process(@context,@options)
        
        @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize].should be_an_instance_of(Hash)
      end
      
      context 'content attributes' do
        
        it 'should output the attributes of the content' do
          field = @content_type.content_custom_fields.first
          Locomotive::Export::ContentTypes.process(@context,@options)
          
          @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize]['email'].should == @content.email
        end
        
      end
      
    end
    
    context 'content assets' do
      
      it 'should create content assets' do
        FileUtils.mkdir_p("#{Rails.root}/public/sites/test")
        FileUtils.cp("#{Rails.root}/spec/fixtures/assets/5k.png","#{Rails.root}/public/sites/test/5k.png")
        
        @template = File.join(Rails.root,'tmp','themes',@site.id.to_s,"public","samples",@content_type.name,"5k.png")
        
        File.exists?(@template).should be_false
        
        @content = ContentInstance.new
        @content.stubs(:_slug).returns("some_content")
        @content.stubs(:aliased_attributes).returns({ "email" => "email@email.com", "photo" => "/sites/test/5k.png"})
        ContentType.any_instance.stubs(:contents).returns([@content])
        Locomotive::Export::ContentTypes.process(@context,@options)
        
        File.exists?(@template).should be_true
        File.readable?(@template).should be_true
        File.size?(@template).should be_true
        
        FileUtils.rm_rf("#{Rails.root}/public/sites/test")
      end
      
    end
    
  end
  
end