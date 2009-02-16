require File.dirname(__FILE__) + '/../spec_helper'

describe 'a custom email', :shared => true do
  it 'should use the Redmine method if no recipient is passed'
  
  it 'should set the recipient to only one user' do
    mail = Mailer.create_issue_add(@issue, @author.mail)
    mail.bcc.size.should eql(1)
  end

  it 'should display the Deliverable subject if the Budget plugin is present' do
    @issue.deliverable = mock_model(Deliverable, :subject => "Take over the world")
    mail = create_mail
    mail.body.should match(/take over the world/i)
  end

  it 'should show the total time spent on the issue if the user has the :view_time_entries permission' do
    @issue.estimated_hours = 20
    @issue.should_receive(:spent_hours).at_least(:twice).and_return(10)
    @author.should_receive(:allowed_to?).at_least(:twice).with(:view_time_entries, @project).and_return(true)
    User.should_receive(:find_by_mail).with(@author.mail).and_return(@author)

    mail = create_mail
    mail.body.should match(/10 of 20.0 hours/i)
  end

  it 'should not show the total time spent on the issue if the user doesnt have the :view_time_entries permission' do
    @issue.estimated_hours = 20
    @author.stub!(:allowed_to?).with(:view_time_entries, @project).and_return(false)
    User.should_receive(:find_by_mail).with(@author.mail).and_return(@author)

    mail = create_mail
    mail.body.should_not match(/hours/i)
  end

  describe 'with a Deliverable' do
    before(:each) do
      @issue.deliverable = mock_model(HourlyDeliverable,
                                      :subject => "Take over the world",
                                      :labor_budget => 200.0,
                                      :spent => 100.0)
      @author.stub!(:allowed_to?).with(:view_time_entries, @project).and_return(false)
      User.stub!(:find_by_mail).with(@author.mail).and_return(@author)
    end

    describe 'with the :manage_budget permission' do
      before(:each) do
        @author.stub!(:allowed_to?).with(:manage_budget, @project).and_return(true)
      end

      it 'should show the labor budget' do
        mail = create_mail
        mail.body.should match(/\$200.0/i)
      end

      it 'should show the labor budget spent' do
        mail = create_mail
        mail.body.should match(/\$100.0/i)
      end
    end

    describe 'without the :manage_budget permission' do
      before(:each) do
        @author.stub!(:allowed_to?).with(:manage_budget, @project).and_return(false)
      end

      it 'should not show the labor budget' do
        mail = create_mail
        mail.body.should_not match(/200.0/i)
      end

      it 'should not show the labor budget spent' do
        mail = create_mail
        mail.body.should_not match(/100.0/i)
      end

    end
  end
end

describe Mailer, "#issue_add" do
  def create_mail
    return Mailer.create_issue_add(@issue, @author.mail)
  end

  before(:each) do
    @author = mock_model(User, :name => 'Mock', :login => 'mock', :mail => 'test@example.com')
    @project = mock_model(Project, :name => 'test', :identifier => 'test')
    @issue = Issue.new(:author => @author, :project => @project)
    @author.stub!(:allowed_to?).with(:view_time_entries, @project).and_return(false)
    @author.stub!(:allowed_to?).with(:manage_budget, @project).and_return(false)
  end

  it_should_behave_like 'a custom email'
end

describe Mailer, "#issue_edit" do
  def create_mail
    return Mailer.create_issue_edit(@journal, @author.mail)
  end


  before(:each) do
    @author = mock_model(User, :name => 'Mock', :login => 'mock', :mail => 'test@example.com', :pref => { })
    @project = mock_model(Project, :name => 'test', :identifier => 'test')
    @author.stub!(:allowed_to?).with(:view_time_entries, @project).and_return(false)
    @author.stub!(:allowed_to?).with(:manage_budget, @project).and_return(false)
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

  it_should_behave_like 'a custom email'
end
