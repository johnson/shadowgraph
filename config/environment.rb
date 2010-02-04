# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # 加载应用配置信息
  CONFIG = YAML.load_file("#{RAILS_ROOT}/config/app_config.yml")[RAILS_ENV]
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )  
  # %w(observers sweepers mailers middleware).each do |dir|
  #   config.load_paths << "#{RAILS_ROOT}/app/#{dir}"
  # end
  # 增加rack middleware
  config.load_paths << "#{RAILS_ROOT}/app/middleware"

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'
  # 封装ffmpeg的gem，按如下方法安装最新的兼容ffmpeg0.5的版本
  # sudo gem install echoe
  # sudo gem install open4
  # sudo gem install flvtool2
  # git clone git://github.com/newbamboo/rvideo.git
  # cd rvideo
  # rake repackage
  # sudo rake install
  config.gem 'echoe'
  config.gem 'open4'
  config.gem 'rvideo', :version => '~> 0.9.6', :source => 'http://gemcutter.org'
  config.gem 'RubyInline' if RUBY_PLATFORM =~ /Linux/
  # 角色控制和访问控制列表
  # config.gem "acl9", :source => "http://gemcutter.org", :lib => "acl9" # 用plugin版
  # mime-types插件
  # config.gem 'mime-types', :lib => 'mime/types' # 用mimetype_fu代替

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  # config.time_zone = 'Beijing'
  config.time_zone = CONFIG['time_zone'] || 'UTC'  

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  # config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]  
  config.i18n.default_locale = CONFIG['default_locale'] || 'en'


  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

	#config.active_record.allow_concurrency = true

end

