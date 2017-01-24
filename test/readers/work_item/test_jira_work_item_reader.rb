require 'minitest/autorun'
require 'minitest/mock'
require 'shoulda/matchers'
require 'shoulda/context'

require_relative '../../../lib/readers/work_item/jira_work_item_reader'

class TestJiraWorkItemReader < Minitest::Test

  context 'JiraWorkItemReader' do

    should 'return an item for query using mocks' do
      @config = {:jira_config => {:props => {:url => 'https://sample.atlassian.net/', :username => 'username', :password => 'password'}, :query => 'project = "KanbanDashboard" and status = "Done"'}}

      issues = [JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:08.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.000+1100"}}}),
                JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:01.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.000+1100"}}}),
                JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:05.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.533+1100"}}})]
      client = MiniTest::Mock.new
      issue_factory = MiniTest::Mock.new
      client.expect :Issue, issue_factory
      issue_factory.expect :jql, issues, [@config[:jira_config][:query]]

      reader = JiraWorkItemReader.new(@config)

      JIRA::Client.stub :new, client do
        work_items = reader.read_data
        assert_equal 3, work_items.size
        counter =0
        issues.each { |issue|
          assert_equal work_items[counter].start_date, DateTime.parse(issue.attrs['fields']['created']).strftime(WorkItem::DATE_FORMAT)
          assert_equal work_items[counter].complete_date, DateTime.parse(issue.attrs['fields']['resolutiondate']).strftime(WorkItem::DATE_FORMAT)
          counter +=1
        }
      end
      client.verify
      issue_factory.verify
    end

    should 'override start and complete column names from configuration' do
      @config = {:jira_config => {:props => {:url => 'https://sample.atlassian.net/', :username => 'username', :password => 'password'},
                                  :query => 'project = "KanbanDashboard" and status = "Done"'},
                 :start_date_column => 'ready_for_work_date',
                 :complete_date_column => 'complete_date'}

      issues = [JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:08.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.000+1100",
                                                                        'ready_for_work_date' => "2017-01-18T17:48:08.000+1100", 'complete_date' => "2017-01-20T12:02:29.000+1100"}}}),
                JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:01.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.000+1100",
                                                                        'ready_for_work_date' => "2017-01-18T17:48:01.000+1100", 'complete_date' => "2017-01-20T12:02:29.000+1100"}}}),
                JIRA::Resource::Issue.new(nil, {:attrs => {'fields' => {'created' => "2017-01-17T17:48:05.000+1100", 'resolutiondate' => "2017-01-19T12:02:29.533+1100",
                                                                        'ready_for_work_date' => "2017-01-18T17:48:05.000+1100", 'complete_date' => "2017-01-20T12:02:29.533+1100"}}})]
      client = MiniTest::Mock.new
      issue_factory = MiniTest::Mock.new
      client.expect :Issue, issue_factory
      issue_factory.expect :jql, issues, [@config[:jira_config][:query]]

      reader = JiraWorkItemReader.new(@config)

      JIRA::Client.stub :new, client do
        work_items = reader.read_data
        assert_equal 3, work_items.size
        counter =0
        issues.each { |issue|
          assert_equal work_items[counter].start_date, DateTime.parse(issue.attrs['fields']['ready_for_work_date']).strftime(WorkItem::DATE_FORMAT)
          assert_equal work_items[counter].complete_date, DateTime.parse(issue.attrs['fields']['complete_date']).strftime(WorkItem::DATE_FORMAT)
          counter +=1
        }
      end
      client.verify
      issue_factory.verify
    end

    should 'throw exception if configuration not matching endpoint' do
      @config = {:jira_config => {:props => {:url => 'https://localhost:8080', :username => 'username', :password => 'password'}, :query => 'project = "MyProject"'}}
      raises_exception = -> { raise ArgumentError.new }
      reader = JiraWorkItemReader.new(@config)

      assert_raises RuntimeError do
        JIRA::Client.stub :new, raises_exception do
          reader.read_data
        end
      end
    end
  end
end