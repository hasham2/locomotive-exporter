## Site ##
Factory.define :site do |s|
  s.name 'Acme Website'
  s.meta_keywords 'acme company products anvil rocket'
  s.meta_description 'acme is a company that sells products'
  s.subdomain 'acme'
  s.created_at Time.now
end

Factory.define "test site", :parent => :site do |s|
  s.name 'Locomotive test website'
  s.subdomain 'acme-test'
  s.after_build do |site_test|
    site_test.memberships.build :account => (Site.first.present? ? Site.first.memberships.first.account : Factory("admin user")), :admin => true, :role => %(admin)
  end
end

Factory.define "another site", :parent => "test site" do |s|
  s.name "Locomotive test website #2"
  s.subdomain "acme-test-2"
end


# Accounts ##
Factory.define :account do |a|
  a.name 'Bart Simpson'
  a.email 'bart@simpson.net'
  a.password 'easyone'
  a.password_confirmation 'easyone'
  a.locale 'en'
end

Factory.define "admin user", :parent => :account do |a|
  a.name "Admin"
  a.email "admin@locomotiveapp.org"
  a.admin true
end

Factory.define "frenchy user", :parent => :account do |a|
  a.name "Jean Claude"
  a.email "jean@frenchy.fr"
  a.locale 'fr'
end

Factory.define "brazillian user", :parent => :account do |a|
  a.name "Jose Carlos"
  a.email "jose@carlos.com.br"
  a.locale 'pt-BR'
end


## Memberships ##
Factory.define :membership do |m|
  m.admin true
  m.account { Account.where(:name => "Bart Simpson").first || Factory('admin user') }
end

Factory.define :admin, :parent => :membership do |m|
  m.admin true
  m.account { Factory('admin user', :locale => 'en') }
end

Factory.define :owner, :parent => :membership do |m|
  m.admin false
  m.role %(owner)
  m.account { Factory('frenchy user', :locale => 'en') }
end

Factory.define :editor, :parent => :membership do |m|
  m.admin false
  m.role %(editor)
  m.account { Factory('brazillian user', :locale => 'en') }
end
## Pages ##
Factory.define :page do |p|
  p.title 'Home page'
  p.slug 'index'
  p.published true
  p.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Snippets ##
Factory.define :snippet do |s|
  s.name 'My website title'
  s.slug 'header'
  s.template %{<title>Acme</title>}
  s.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Theme assets ##
Factory.define :theme_asset do |a|
  a.site { Site.where(:subdomain => "acme").first || Factory(:site) }
end


## Asset collections ##
Factory.define :asset_collection do |s|
  s.name 'Trip to Chicago'
  s.slug 'chicago'
  s.site { Site.where(:subdomain => "acme").first || Factory(:site) }
  s.asset_custom_fields [{ :label => "city", :kind => "string" }, { :label => "people", :kind => "text"}]
end


## Content types ##
Factory.define :content_type do |t|
  t.name 'My project'
  t.site { Site.where(:subdomain => "acme").first || Factory(:site) }
  t.content_custom_fields [{ :label => "email", :kind => "string" }, { :label => "photo", :kind => "file"}]
end
