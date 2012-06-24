# Rails Template for apps with
#   twitter bootstrap, haml, simple_form
#   rspec, capybara, factorygirl
#   git, heroku

#====== git =======
git :init
git :add => ".", :commit => "-am 'First commit!'"

#====== gems =======
#??gem("sqlite3", :delete)
gsub_file 'Gemfile', /gem 'sqlite3'/, ''

gem 'haml-rails'
gem 'simple_form'
gem 'decent_exposure'
gem 'squeel'

gem_group :assets do
  #gem 'twitter-bootstrap-rails'
  gem 'bootstrap-sass'
end

gem_group :development, :test do
  gem 'debugger'
  gem 'sqlite3'

  gem "rspec-rails"
  gem 'rspec-instafail'
  gem 'database_cleaner'

  gem "capybara"
  gem 'capybara-webkit'
  gem "selenium-webdriver"
  gem 'launchy' # provides save_and_open_page

  gem 'factory_girl_rails'
  gem 'faker'
end

gem_group :development do
  gem 'heroku'
end

gem_group :production do
  gem 'thin'
  gem 'pg'
end

run "bundle install --without production"

#====== install =======
generate 'simple_form:install --bootstrap'
generate 'rspec:install'
#run %Q^rails generate simple_form:install --bootstrap^
#run %Q^rails generate rspec:install^

git :add => ".", :commit => "-am 'Installs'"

#====== stylesheets =======
create_file 'app/assets/stylesheets/bootstrap_and_overrides.css.scss' do
%Q^/*$baseFontSize: 16px;*/
/*$baseFontFamily: Georgia,Cambria,"Times New Roman",Times,serif; // $serifFontFamily;*/
@import "bootstrap";
body { padding-top: 70px; }
@import "bootstrap-responsive";
^
end

create_file 'app/assets/stylesheets/layout.css.scss'

run %Q^ mv 'app/assets/stylesheets/application.css' 'app/assets/stylesheets/application.css.scss' ^

gsub_file 'app/assets/stylesheets/application.css.scss', 'require_tree .', 'depend_on "bootstrap_and_overrides.css.scss"'

append_to_file 'app/assets/stylesheets/application.css.scss' do
%Q^
@import "bootstrap_and_overrides.css.scss";
@import "layout.css.scss";
^
end

#====== javascripts =======
insert_into_file 'app/assets/javascripts/application.js', "\n//= require bootstrap", :after => '//= require jquery_ujs'

git :add => ".", :commit => "-am 'Initial assets'"

#====== layout =======
insert_into_file 'app/helpers/application_helper.rb', :after => 'module ApplicationHelper' do
%Q^
  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def body_id(id)
    content_for(:body_id) { id }
  end
^
end

run "rm app/views/layouts/application.html.erb"

create_file 'app/views/layouts/application.html.haml' do
%Q^!!!
%html
  %head
    %title= '#{app_name.capitalize} | ' + yield(:title)
    /[if lt IE 9]
      %script{"src" => "http://html5shim.googlecode.com/svn/trunk/html5.js", "type" => "text/javascript"}
    %meta{"http-equiv"=>"Content-Type", :content=>"text/html; charset=utf-8"}
    %meta{"name" => "viewport", "content" => "width=device-width, initial-scale=1.0"}
    = csrf_meta_tag
    = stylesheet_link_tag "application", :media => "all"
    = javascript_include_tag "application"
    %script
      = yield :javascripts
      $(function() {
      = yield :javascript_ready
      });

    = yield(:head)
  %body{ :id => yield(:body_id) }
    = render 'layouts/navbar'
    = render 'layouts/banner'
    #content
      .container-fluid
        = render 'layouts/flash', flash: flash
        - if show_title?
          %h1= yield(:title)
        = content_for?(:content) ? yield(:content) : yield
    = render 'layouts/footer'
^
end

create_file 'app/views/layouts/_flash.html.haml' do
%Q^- flash.each do |name, msg|
  = content_tag :div, :class => "alert alert-\#{name == :notice ? 'success' : 'error'}" do
    %a.close{ "data-dismiss" => "alert" }
      %i.icon-remove
    = msg
^
end

create_file 'app/views/layouts/_navbar.html.haml' do
%Q^.navbar.navbar-fixed-top
  .navbar-inner
    .container-fluid
      %a.btn.btn-navbar{ 'data-toggle' => 'collapse', 'data-target' => ".nav-collapse"}
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
        %span.icon-bar
      %h1 #{app_name.capitalize}
      .nav-collapse
        %ul.nav
          %li= link_to "Home", root_path
          %li= link_to "Aaaa", ''
          %li= link_to 'Bbbb', ''
          %li= link_to 'Cccc', ''
^  
end

create_file 'app/views/layouts/_banner.html.haml' do
  '#banner'
end

create_file 'app/views/layouts/_footer.html.haml' do
%Q^#footer
  .container-fluid
    .align_right
      Copyright &copy; 2012 
      = link_to "Parkerhill Technology Group LLC", "http://parkerhill.com"
^
end

git :add => ".", :commit => "-am 'Added layout'"

#====== pages =======

run "rm public/index.html"

route %Q^
  match 'about' => 'pages#about'
  root :to => 'pages#home'
^

create_file 'app/controllers/pages_controller.rb' do
%Q^
class PagesController < ApplicationController
end
^
end

create_file 'app/views/pages/home.html.haml' do
%Q^
%h1 Home
%p Welcome to my app.
^
end

create_file 'app/views/pages/about.html.haml' do
%Q^
%h1 About
%p TBD
^
end

create_file 'spec/requests/pages_spec.rb' do
%Q^
require 'spec_helper'

describe "Pages", :type => :request do
  describe "GET /" do
    it "is on the home page" do
      visit '/'
      current_path.should == '/'
    end
  end
  describe "GET /about" do
    it "is on the About page" do
      visit '/about'
      current_path.should == '/about'
    end
  end
end
^
end

git :add => ".", :commit => "-am 'Initial pages'"

rake 'db:migrate'
rake 'spec'

#====== more? =======
# devise, omniauth, cancan
# application_settings


#====== heroku =======

if yes?("Would you like to create a Heroku site?")
  comment_lines 'config/application.rb', /Bundler.require\(\*Rails.groups\(:assets => %w\(development test\)\)\)/
  uncomment_lines 'config/application.rb', /Bundler.require\(:default, :assets, Rails.env\)/
  git :add => ".", :commit => "-am 'For Heroku'"

  run "heroku create --stack cedar"
  run "heroku apps:rename #{app_name.downcase}"
  git :push => 'heroku master'
  run "heroku run rake db:migrate"
  #run "heroku run rake db:seed"
  run "heroku open"
end


