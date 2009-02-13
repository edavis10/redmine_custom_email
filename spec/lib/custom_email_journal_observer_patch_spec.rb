require File.dirname(__FILE__) + '/../spec_helper'

describe JournalObserver, '#after_create' do
  before(:each) do
    @issue = mock_model(Issue, :watcher_recipients => [], :recipients => [])
    @journal = mock_model(Journal, :journalized => @issue)
    
  end

  it 'should send a single email for each recipient' do
    @issue.stub!(:recipients).and_return(['1','2','3','4'])
    Mailer.should_receive(:deliver_issue_edit).at_least(4).times
    JournalObserver.instance.after_create(@journal)
  end

  it 'should send an email to the issue recipients' do
    @issue.should_receive(:recipients).and_return(['1','2','3','4'])
    Mailer.should_receive(:deliver_issue_edit).at_least(4).times
    JournalObserver.instance.after_create(@journal)
  end

  it 'should send an email to the issue watchers' do
    @issue.should_receive(:watcher_recipients).and_return(['1','2','3'])
    Mailer.should_receive(:deliver_issue_edit).at_least(3).times
    JournalObserver.instance.after_create(@journal)
  end
end
