require 'spec_helper'

describe Locomotive::Exporter::Snippets do
  
  before :each do
    @site = Factory(:site)
    @snippet = Factory(:snippet, :site => @site)
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
  
  context 'snippet templates' do
    
    it 'should create snippet templates' do
      @template = File.join(Rails.root,'tmp','themes',@site.id.to_s,'snippets',%{#{@site.snippets.first.slug}.liquid})
      
      File.exists?(@template).should be_false
      
      Locomotive::Exporter::Snippets.process(@context,@options)
      
      File.exists?(@template).should be_true
      File.readable?(@template).should be_true
      File.size?(@template).should be_true
    end
    
  end
  
  after :each do
    FileUtils.rm_r(File.join(Rails.root,'tmp','themes'),:force => true)
  end
  
end
