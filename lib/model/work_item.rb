require 'date'

class WorkItem

  DATE_FORMAT = "%d/%m/%Y"

  attr_accessor :start_date, :complete_date, :class_of_service, :additional_values

  def initialize args
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    if @additional_values.nil?
      @additional_values = Hash.new
    end
  end

  def lead_time
    lead_time = (Date.strptime(@complete_date, DATE_FORMAT) - Date.strptime(@start_date, DATE_FORMAT)).to_i
    if lead_time == 0
      lead_time = 1
    end
    lead_time
  end

  def to_s
    "Start Date: " + @start_date + ", Complete Date: " + @complete_date + ", Class of Service: " + @class_of_service
  end
end