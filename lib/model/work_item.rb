require 'date'

class WorkItem

  DATE_FORMAT = "%d/%m/%y"

  attr_accessor :start_date, :complete_date, :class_of_service, :additional_values

  def initialize args
    @additional_values = Hash.new
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def lead_time
    lead_time = (Date.strptime(@complete_date, DATE_FORMAT) - Date.strptime(@start_date, DATE_FORMAT)).to_i
    if lead_time == 0
      lead_time = 1
    end
    lead_time
  end
  
  def start_week_string
    convert_to_week_string(@start_date)
  end

  def to_s
    "Start Date: " + @start_date + ", Complete Date: " + @complete_date + ", Class of Service: " + @class_of_service
  end

  def as_json(options={})
      {
          start_date: @start_date,
          complete_date: @complete_date,
          class_of_service: @class_of_service,
      }
  end

  def to_json(*options)
      as_json(*options).to_json(*options)
  end

  def complete_week_string
    convert_to_week_string(@complete_date)
  end

  private def convert_to_week_string(date)
    converted_date = (Date.strptime(date, DATE_FORMAT))
    converted_date.strftime('%Y') + "-" + converted_date.strftime('%U')
  end


end