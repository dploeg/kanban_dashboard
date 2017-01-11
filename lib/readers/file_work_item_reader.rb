require "json"


class FileWorkItemReader

  attr_reader :work_items

  def initialize(file_name)
    @file_name = file_name
    @work_items = Array.new
  end

  def read_data
    file = File.read(@file_name)
    begin
      input_data = JSON.parse(file)
      input_data.each { |input_hash|
        work_item = WorkItem.new(input_hash)
        @work_items.push(work_item)
      }
    rescue => error
      raise RuntimeError.new(error)
    end
  end

end