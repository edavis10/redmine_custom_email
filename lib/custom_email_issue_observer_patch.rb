module CustomEmailIssueObserverPatch
  def after_create(issue)
    if self.send_notification && Setting.notified_events.include?('issue_added')
      # Recipient and watchers should be emails
      (issue.recipients + issue.watcher_recipients).uniq.each do |recipient|
        Mailer.deliver_issue_add(issue, recipient)
      end
    end
    clear_notification
  end
end

