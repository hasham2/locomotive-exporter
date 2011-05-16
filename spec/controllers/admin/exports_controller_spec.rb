require 'spec_helper'

describe Admin::ExportsController do

  before :all do
    @site             = Site.first || Factory.create(:site)
    @page_one         = Factory.create(:page, :site => @site, :slug => 'first', :raw_template => '')
    @page_two         = Factory.create(:page, :site => @site, :slug => 'second', :raw_template => '')
    @asset_collection = Factory.create(:asset_collection, :site => @site)
    @asset_one        = Factory.create(:asset, :collection => @asset_collection, :source => File.open(Rails.root.join('spec', 'support', 'assets', '5k.png')))
    @account          = Factory.create(:account)
    @site.memberships.create!(:account => @account, :admin => true)
  end

  after :all do
    # Cleanup
    @site.destroy
    @page_one.destroy
    @page_two.destroy
  end

  describe '#new' do

    context 'when the user is logged in' do

      before :each do
        sign_in @account
      end

      context 'when exporting is successful' do

        it 'should be a successful response' do
          get :new
          debugger
          puts response.body.inspect
          response.should be_successful
        end

        it 'saves to a zip' do

        end

        it 'returns the zip to the browser'

        it 'removes the zip'

      end

      context 'when exporting fails' do

        it 'logs the error'

        it 'logs the backtrace'

        it 'displays an alert flash message'

        it 'redirects to the admin home page'

      end

    end

  end

  context 'when the user is not logged in' do

  end

end
