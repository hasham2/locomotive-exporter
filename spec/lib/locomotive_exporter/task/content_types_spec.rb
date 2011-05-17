require 'spec_helper'

describe LocomotiveExporter::Task::ContentTypes do

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
      LocomotiveExporter::Task::ContentTypes.process(@context,@options)

      @context[:database]['site']['content_types'].should_not be_empty
    end

    it 'should define next pages hashes' do
      LocomotiveExporter::Task::ContentTypes.process(@context,@options)

      @context[:database]['site']['content_types'][@content_type.name].should_not be_empty
    end

    it 'should define the following content_type default attributes' do
      LocomotiveExporter::Task::ContentTypes.process(@context,@options)

      %w(slug name description api_enabled).each do |method|
        @context[:database]['site']['content_types'][@content_type.name][method].should == @content_type.send(method)
      end
    end

    context 'custom attributes' do

      context 'order_by' do

        it 'should use created_at if none is set' do
          stub(@content_type).order_by { nil }
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should == 'created_at'
        end

        it 'should use the human name on a custom field' do
          stub(@content_type).order_by { 'custom_field_1' }
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should == 'email'
        end

        it 'should not send any order_by if set to _position_in_list' do
          stub(@content_type).order_by { '_position_in_list' }
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

          @context[:database]['site']['content_types'][@content_type.name]['order_by'].should be_nil
        end

      end

      context 'highlighted_field_name' do

        it 'should use the human name' do
          field = @content_type.content_custom_fields.first
          stub(@content_type).highlighted_field { field }
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

          @context[:database]['site']['content_types'][@content_type.name]['highlighted_field_name'].should == field._alias
        end

      end

    end

    context 'custom fields' do

      it 'should return a hash of custom fields' do
        LocomotiveExporter::Task::ContentTypes.process(@context,@options)

        @context[:database]['site']['content_types'][@content_type.name]['fields'].should be_an_instance_of(Array)
        @context[:database]['site']['content_types'][@content_type.name]['fields'][0].should be_an_instance_of(Hash)
      end

      it 'should have a hash for each content_type name by their label' do
        field = @content_type.content_custom_fields.first
        LocomotiveExporter::Task::ContentTypes.process(@context,@options)

        @context[:database]['site']['content_types'][@content_type.name]['fields'][0][field.label].should be_an_instance_of(Hash)
      end

      context 'field attributes' do

        it 'should output the attributes of the field' do
          field = @content_type.content_custom_fields.first
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

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
        LocomotiveExporter::Task::ContentTypes.process(@context,@options)

        @context[:database]['site']['content_types'][@content_type.name]['contents'].should be_an_instance_of(Array)
        @context[:database]['site']['content_types'][@content_type.name]['contents'][0].should be_an_instance_of(Hash)
      end

      it 'should have a hash for each content_type name by their slug' do
        field = @content_type.content_custom_fields.first
        LocomotiveExporter::Task::ContentTypes.process(@context,@options)

        @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize].should be_an_instance_of(Hash)
      end

      context 'content attributes' do

        it 'should output the attributes of the content' do
          field = @content_type.content_custom_fields.first
          LocomotiveExporter::Task::ContentTypes.process(@context,@options)

          @context[:database]['site']['content_types'][@content_type.name]['contents'][0][@content._slug.humanize]['email'].should == @content.email
        end

      end

    end

    context 'content assets' do

      it 'should create content assets' do

        pending 'refactoring requires this test to be rewritten, please rewrite at the next opportunity, MV'

        FileUtils.mkdir_p("#{Rails.root}/public/sites/test")
        FileUtils.cp("#{Rails.root}/spec/support/assets/5k.png","#{Rails.root}/public/sites/test/5k.png")

        @template = File.join(Rails.root,'tmp','themes',@site.id.to_s,"public","samples",@content_type.name,"5k.png")

        File.exists?(@template).should be_false

        @content = ContentInstance.new
        LocomotiveExporter::Task::ContentTypes.process(@context,@options)

        File.exists?(@template).should be_true
        File.readable?(@template).should be_true
        File.size?(@template).should be_true

        FileUtils.rm_rf("#{Rails.root}/public/sites/test")
      end

    end

  end

end
