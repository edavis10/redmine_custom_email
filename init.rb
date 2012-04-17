require 'redmine'

# Patches to the Redmine core.
require 'dispatcher'

Dispatcher.to_prepare :redmine_custom_email do
  require_dependency 'journal_observer'
  JournalObserver.instance.extend(CustomEmailJournalObserverPatch)

  require_dependency 'mailer'
  Mailer.send(:include, CustomEmailMailerPatch)

  require_dependency 'question_mailer'
  require 'custom_email_question_mailer_patch' # TODO: Rename
  QuestionMailer.send(:include, CustomEmail::Patch::QuestionMailer)
end

Redmine::Plugin.register :redmine_custom_email do
  name 'Custom Email plugin'
  author 'Eric Davis'
  author_url 'http://www.littlestreamsoftware.com'
  description "Plugin to customize the way email is delivered"
  version '0.1.0'

  requires_redmine :version_or_higher => '0.8.0'

end
