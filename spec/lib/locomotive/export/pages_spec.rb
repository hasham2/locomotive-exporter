require 'spec_helper'

describe Locomotive::Export::Pages do
  
  before :each do
    @site = Factory(:site)
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
    
    before :each do
      Locomotive::Export::Pages.any_instance.stubs(:export_template).returns(true)
    end
    
    it 'should define a pages hash' do
      Locomotive::Export::Pages.process(@context,@options)
      
      @context[:database]['site']['pages'].should be_an_instance_of(Array)
      @context[:database]['site']['pages'][0].should be_an_instance_of(Hash)
    end
    
    it 'should define next pages hashes' do
      Locomotive::Export::Pages.process(@context,@options)
      
      @context[:database]['site']['pages'][0][@site.pages.first.fullpath].should be_an_instance_of(Hash)
      @context[:database]['site']['pages'][0][@site.pages.first.fullpath].should_not be_empty
    end
    
    it 'should define the following page attributes' do
      Locomotive::Export::Pages.process(@context,@options)
      
      page = @site.pages.first
      @context[:database]['site']['pages'][0][page.fullpath]['title'].should          == page.title
      @context[:database]['site']['pages'][0][page.fullpath]['published'].should      == page.published
      @context[:database]['site']['pages'][0][page.fullpath]['templatized'].should    == false
      @context[:database]['site']['pages'][0][page.fullpath]['cache_strategy'].should == page.cache_strategy
    end
    
    it 'should not define any more page attributes' do
      Locomotive::Export::Pages.process(@context,@options)
      
      page = @site.pages.first
      @context[:database]['site']['pages'][0][page.fullpath].size.should === 6
    end
    
    it 'should replace content_type_template with template in the slug' do
      Page.any_instance.stubs(:fullpath).returns("content_type_template")
      
      Locomotive::Export::Pages.process(@context,@options)
      
      @context[:database]['site']['pages'][0]["template"].should_not be_empty
    end
    
    it 'should define the content_type on templatized pages' do
      @content_type = Factory.build(:content_type)
      @site.pages.first.update_attributes!(:templatized => true, :content_type => @content_type)
      Page.any_instance.stubs(:content_type).returns(@content_type)

      Locomotive::Export::Pages.process(@context,@options)
      
      @context[:database]['site']['pages'][0]["content_type"].should == @content_type.slug
    end
    
  end
  
  context 'page templates' do
    
    it 'should create page templates' do
      @template = File.join(Rails.root,'tmp','themes',@site.id.to_s,'templates',%{#{@site.pages.first.fullpath}.liquid})
      
      File.exists?(@template).should be_false
      
      Locomotive::Export::Pages.process(@context,@options)
      
      File.exists?(@template).should be_true
      File.readable?(@template).should be_true
      File.size?(@template).should be_true
    end
    
  end
  
  after :each do
    FileUtils.rm_r(File.join(Rails.root,'tmp','themes'),:force => true)
  end
  
end
