require File.dirname(__FILE__) + '/../spec_helper'

describe Mailer, "#issue_add" do
  before(:each) do
    @author = mock_model(User, :name => 'Mock', :login => 'mock', :email => 'test@example.com')
    @project = mock_model(Project, :name => 'test', :identifier => 'test')
    @issue = Issue.new(:author => @author, :project => @project)
  end

  it 'should use the Redmine method if no recipient is passed'
  
  it 'should set the recipient to only one user' do
    mail = Mailer.create_issue_add(@issue, @author.email)
    mail.bcc.size.should eql(1)
  end

  it 'should display the Deliverable subject if the Budget plugin is present' do
    @issue.deliverable = mock_model(Deliverable, :subject => "Take over the world")
    mail = Mailer.create_issue_add(@issue, @author.email)
    mail.body.should match(/take over the world/i)
  end
end

describe Mailer, "#issue_edit" do
  before(:each) do
    @author = mock_model(User, :name => 'Mock', :login => 'mock', :email => 'test@example.com', :pref => { })
    @project = mock_model(Project, :name => 'test', :identifier => 'test')
    @tracker = mock_model(Tracker, :name => "Bug")
    @issue = Issue.new(:author => @author, :project => @project, :tracker => @tracker)
    @journal_details = mock_model(JournalDetail, :each => [])
    @journal = mock_model(Journal,
                          :journalized => @issue,
                          :user => @author,
                          :notes => "A journal update",
                          :notes? => true,
                          :details => @journal_details)
  end

  it 'should use the Redmine method if no recipient is passed'
  
  it 'should set the recipient to only one user' do
    mail = Mailer.create_issue_edit(@journal, @author.email)
    mail.bcc.size.should eql(1)
  end

  it 'should display the Deliverable subject if the Budget plugin is present' do
    @issue.deliverable = mock_model(Deliverable, :subject => "Take over the world")
    mail = Mailer.create_issue_edit(@journal, @author.email)
    mail.body.should match(/take over the world/i)
  end
end
