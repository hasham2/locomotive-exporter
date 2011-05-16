require 'spec_helper'

describe Locomotive::Exporter::Site do
  
  before :each do
    @site = Factory(:site)
    @database = { 'site' => {} }
    @context = { 
      :site       => @site, 
      :database   => @database, 
      :theme_path => @theme_path, 
      :error      => nil, 
      :worker     => @worker 
    }
    @options = {}
  end
  
  context 'site database hash' do
  
    it 'should define the following attributes' do
      Locomotive::Exporter::Site.process(@context,@options)
      
      @context[:database]['site']['name'].should == @site.name
      @context[:database]['site']['meta_keywords'].should == @site.meta_keywords
      @context[:database]['site']['meta_description'].should == @site.meta_description
    end
    
    it 'should not define any more' do
      Locomotive::Exporter::Site.process(@context,@options)
      
      @context[:database]['site'].size.should === 3
    end
    
  end
  
end
