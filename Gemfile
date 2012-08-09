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
end