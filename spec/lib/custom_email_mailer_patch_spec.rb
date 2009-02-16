require File.dirname(__FILE__) + '/../spec_helper'

describe Mailer, "#issue_add_with_recipient" do
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
