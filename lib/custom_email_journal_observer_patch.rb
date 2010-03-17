module CustomEmailJournalObserverPatch
  def after_create(journal)
    if self.send_notification && Setting.notified_events.include?('issue_updated')
      # Recipient and watchers should be emailed
      issue = journal.journalized
      recipients = (issue.recipients + issue.watcher_recipients)

      # Add in the question recipient
      if journal.question && journal.question.assigned_to && journal.question.assigned_to.mail
        recipients << journal.question.assigned_to.mail
      end

      # Add in any question askers.
      if issue.pending_question?(journal.user)
        issue.open_questions.all.each do |question|
          if question.assigned_to == journal.user && question.author && question.author.mail
            recipients << question.author.mail
          end
        end
      end

      recipients.uniq.each do |recipient|
        Mailer.deliver_issue_edit(journal, recipient)
      end
    end
    clear_notification
  end
end

