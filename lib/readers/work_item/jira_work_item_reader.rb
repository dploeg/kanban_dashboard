require 'jira-ruby'

require_relative '../../../lib/model/work_item'

class JiraWorkItemReader

  attr_reader :jira_options

  def initialize(configuration)
    jira_props = configuration[:jira_config][:props]
    url = URI.parse(jira_props[:url])
    @start_date_column = 'created'
    @complete_date_column = 'resolutiondate'
    @jira_options = {
        :username => jira_props[:username],
        :password => jira_props[:password],
        :context_path => url.path,
        :site => url.scheme + "://" + url.host,
        :auth_type => :basic,
        :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE,
        :use_ssl => url.scheme == 'https' ? true : false,
        :proxy_address => jira_props[:proxy_address],
        :proxy_port => jira_props[:proxy_port]
    }
    unless configuration[:start_date_column].nil?
      @start_date_column = configuration[:start_date_column]
    end
    unless configuration[:complete_date_column].nil?
      @complete_date_column = configuration[:complete_date_column]
    end
    @query = configuration[:jira_config][:query]
  end

  def read_data
    @work_items = Array.new
    begin
      client = JIRA::Client.new(@jira_options)
      result = client.Issue.jql(@query)

      result.each { |issue|
        work_item = WorkItem.new({:start_date => retrieve_start_date(issue), :complete_date => retrieve_complete_date(issue)})
        @work_items.push(work_item)
      }
    rescue => error
      raise RuntimeError.new(error)
    end
    @work_items
  end

  def retrieve_complete_date(issue)
    convert_jira_date(issue.attrs['fields'][@complete_date_column])
  end

  def retrieve_start_date(issue)
    convert_jira_date(issue.attrs['fields'][@start_date_column])
  end

  def convert_jira_date(jira_date_string)
    DateTime.parse(jira_date_string).strftime(WorkItem::DATE_FORMAT)
  end
end
