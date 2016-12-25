require 'date'

class WorkItem

  attr_accessor :start_date, :complete_date, :class_of_service

  def initialize args
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def lead_time
    (Date.strptime(@complete_date, "%d/%m/%Y") - Date.strptime(@start_date, "%d/%m/%Y")).to_i
  end

  def to_s
    "Start Date: " + @start_date + ", Complete Date: " + @complete_date + ", Class of Service: " + @class_of_service
  end
end