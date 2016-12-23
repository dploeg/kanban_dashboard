require "json"


class FileDataReader

  @file_name
  @input_data = Array.new

  def initialize(file_name)
    @file_name = file_name
  end

  def read_data
    file = File.read(@file_name)
    begin
      @input_data = JSON.parse(file)
    rescue => error
      raise RuntimeError.new(error)
    end
  end

  # Returns a list of hashes with start_date and complete_date
  def get_input_data
    @input_data
  end
end