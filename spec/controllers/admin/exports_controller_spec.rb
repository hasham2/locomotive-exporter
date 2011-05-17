require 'spec_helper'

describe Admin::ExportsController do

  before :each do
    @site             = Site.first || Factory.create(:site)
    @page_one         = Factory.create(:page, :site => @site, :slug => 'first', :raw_template => '')
    @page_two         = Factory.create(:page, :site => @site, :slug => 'second', :raw_template => '')
    @asset_collection = Factory.create(:asset_collection, :site => @site)
    @asset_one        = Factory.create(:asset, :collection => @asset_collection, :source => File.open(Rails.root.join('spec', 'support', 'assets', '5k.png')))
    @account          = Factory.create(:account)
    @site.memberships.create!(:account => @account, :admin => true)
  end

  describe '#new' do

    context 'when the user is logged in' do

      before :each do
        stub(controller).current_site { @site }
        sign_in @account
      end

      context 'when exporting is successful' do

        before :each do
          get :new
        end

        it 'should be a successful response' do
          response.should be_successful
        end

        it 'saves to a zip' do
          File.should exist Rails.root.join('tmp', 'themes', 'acme_website.zip')
        end

        it 'returns the zip to the browser' do
          response.headers["Content-Disposition"].should include 'filename="Acme Website.zip"'
        end

      end

    end

  end

  context 'when the user is not logged in' do

    before :each do
      get :new
    end

    it 'should redirect to the login url' do
      response.should redirect_to new_admin_session_url
    end

    it 'should display a flash message to the user' do
      flash[:alert].should == 'You need to sign in or sign up before continuing.'
    end

  end

end
