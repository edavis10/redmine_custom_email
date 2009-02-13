require_dependency 'journal_observer'

module CustomEmailJournalObserverPatch
  def after_create(journal)
    if self.send_notification && Setting.notified_events.include?('issue_updated')
      # Recipient and watchers should be emailed
      issue = journal.journalized
      (issue.recipients + issue.watcher_recipients).uniq.each do |recipient|
        Mailer.deliver_issue_edit(journal, recipient)
      end
    end
    clear_notification
  end
end

JournalObserver.instance.extend(CustomEmailJournalObserverPatch)
