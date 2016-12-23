require "json"


class FileDataReader

  @file_name

  def initialize(file_name)
    @file_name = file_name
    @work_items = Array.new
  end

  def read_data
    file = File.read(@file_name)
    begin
      input_data = JSON.parse(file)
      input_data.each { |input_hash|
        work_item = WorkItem.new(:start_date => input_hash['start_date'], :complete_date => input_hash['complete_date'])
        @work_items.push(work_item)
      }
    rescue => error
      raise RuntimeError.new(error)
    end
  end

  def work_items
    @work_items
  end
end