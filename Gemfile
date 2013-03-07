source "http://rubygems.org"

#gemspec :path => 'installer'

group :development, :test do
  # when developing, load from this directory
  path "." do
    %w{access_control activity authentication categories core design i18n
      jobs media menus scaffold versions}.each do |g|
      gem "ubiquo_#{g}"
    end
  end

  gem "sqlite3", "~> 1.3"
  gem "pg", "~> 0.14"
  gem "mysql2", "~> 0.3"
  gem "mocha", "~> 0.10"

  gem 'calendar_date_select', :git => 'git://github.com/gnuine/calendar_date_select'
  gem 'memcache'
  gem 'paper_trail'
  gem 'routing-filter'
  gem 'debugger'
end
