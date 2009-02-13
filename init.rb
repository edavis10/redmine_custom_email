require 'redmine'

require 'custom_email_issue_observer_patch'

Redmine::Plugin.register :redmine_custom_email do
  name 'Custom Email plugin'
  author 'Eric Davis'
  author_url 'http://www.littlestreamsoftware.com'
  description "Plugin to customize the way email is delivered"
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

end
