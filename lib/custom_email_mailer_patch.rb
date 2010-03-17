module CustomEmailMailerPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      # Move old mailer methods to a new name
      alias_method_chain :issue_add, :recipient
      alias_method_chain :issue_edit, :recipient

      helper :custom_email
    end
  end
  
  module InstanceMethods
    def issue_add_with_recipient(issue, recipient = nil)
      if recipient.nil?
        issue_add_without_recipient(issue)
      else
        # Standard Redmine mailer but with only one recipient
        redmine_headers 'Project' => issue.project.identifier,
        'Issue-Id' => issue.id,
        'Issue-Author' => issue.author.login
        redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
        message_id issue
        recipients [recipient] # Only one recipient
        set_from_using_name(issue.author.name) unless issue.author.nil? || issue.author.name.nil?
        subject "#{issue.project.name} - #{issue.subject} ##{issue.id}"
        body(:issue => issue,
             :user => User.find_by_mail(recipient),
             :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue))
        content_type "multipart/alternative"

        part :content_type => "text/plain", :body => render_message("mailer/issue_add.text.plain.rhtml", body)
        part :content_type => "text/html", :body => render_message("mailer/issue_add.text.html.rhtml", body)
      end
    end

    def issue_edit_with_recipient(journal, recipient = nil)
      if recipient.nil?
        issue_edit_without_recipient(journal)
      else
        # Standard Redmine mailer but with only one recipient
        issue = journal.journalized
        redmine_headers 'Project' => issue.project.identifier,
        'Issue-Id' => issue.id,
        'Issue-Author' => issue.author.login
        redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
        # Extra headers for questions
        redmine_headers 'Question-Asked' => true if journal.question
        redmine_headers 'Question-Assigned-To' => journal.question.assigned_to if journal.question && journal.question.assigned_to

        message_id journal
        references issue
        @author = journal.user
        recipients [recipient]
        set_from_using_name(journal.user.name) unless journal.user.nil? || journal.user.name.nil?
        subject "#{issue.project.name} - #{issue.subject} ##{issue.id}"

        # Gets the last opened question on the issue for use in the "Question Answered" email
        closed_question = journal.issue.questions.find(:last,
                                                       :conditions => {:assigned_to_id => journal.user.id, :opened => true}) if journal.user

        body(:issue => issue,
             :journal => journal,
             :closed_question => closed_question,
             :user => User.find_by_mail(recipient),
             :issue_url => url_for(:controller => 'issues', :action => 'show', :id => issue))

        # http://guides.rails.info/action_mailer_basics.html#sending-emails-with-attachments
        part "multipart/alternative" do |pt|
          pt.part :content_type => "text/plain", :body => render_message("mailer/issue_edit.text.plain.rhtml", body)
          pt.part :content_type => "text/html", :body => render_message("mailer/issue_edit.text.html.rhtml", body)
        end

        attach_thumbnails_from_journal(journal)
      end
    end
  end    
end

