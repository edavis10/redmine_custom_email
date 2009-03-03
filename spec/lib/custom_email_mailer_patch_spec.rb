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

  describe 'with an HourlyDeliverable' do
    before(:each) do
      @issue.deliverable = mock_model(HourlyDeliverable,
                                      :subject => "Take over the world",
                                      :labor_budget => 200.0,
                                      :spent => 100.0,
                                      :total_hours => 23,
                                      :hours_used => 12)
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

      it 'should show the total hours budgeted' do
        mail = create_mail
        mail.body.should match(/23 hours/i)
      end

      it 'should show the hours used' do
        mail = create_mail
        mail.body.should match(/12 hours/i)
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

      it 'should not show the total hours budgeted' do
        mail = create_mail
        mail.body.should_not match(/23 hours/i)
      end

      it 'should not show the hours used' do
        mail = create_mail
        mail.body.should_not match(/12 hours/i)
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
                          :issue => @issue,
                          :user => @author,
                          :notes => "A journal update",
                          :notes? => true,
                          :details => @journal_details,
                          :question => nil)
  end

  it_should_behave_like 'a custom email'

  describe 'with an asked question' do
    before(:each) do
      User.should_receive(:find_by_mail).with(@author.mail).and_return(@author)
    end
    
    describe 'to the author' do
      it 'should have "Question Asked" in the body' do
        @question = mock_model(Question,
                               :assigned_to => @author,
                               :author => @author,
                               :issue => @issue)
        @journal.stub!(:question).and_return(@question)

        create_mail.body.should match(/Question asked/i)
      end
    end

    describe 'to someone else' do
      it 'should not "Question Asked" in the body' do
        @question = mock_model(Question,
                               :assigned_to => nil,
                               :author => @author,
                               :issue => @issue)
        @journal.stub!(:question).and_return(@question)

        create_mail.body.should_not match(/Question asked/i)
      end
    end
  end

  describe 'with an answered question' do
    before(:each) do
      User.should_receive(:find_by_mail).with(@author.mail).and_return(@author)

      @journal_for_question = mock_model(Journal, :notes => 'This is a question to answer')
      @closed_question = mock_model(Question,
                                    :assigned_to => nil,
                                    :author => @author,
                                    :journal => @journal_for_question,
                                    :issue => @issue)

      @issue.stub!(:questions).and_return(Question)
      Question.stub!(:find).with(
                                 :last,
                                 :conditions => {:assigned_to_id => @author.id, :opened => true}
                                 ).and_return(@closed_question)
   end
    
   describe 'to the author' do
     it 'should have "Question Answered" in the body' do
        create_mail.body.should match(/Question answered/i)
      end

      it 'should have the original question content in the body' do
        create_mail.body.should match(/#{@journal_for_question.notes}/i)
      end
   end

    describe 'to someone else' do
      before(:each) do
        @closed_question.stub!(:author).and_return(mock_model(User, :name => "Question asker"))
      end
      
      it 'should not "Question Answered" in the body' do
        create_mail.body.should_not match(/Question answered/i)
      end

      it 'should not have the original question content in the body' do
        create_mail.body.should_not match(/#{@journal_for_question.notes}/i)
      end
    end
  end
end
