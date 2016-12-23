require 'date'

class WorkItem

  attr_accessor :start_date, :complete_date

  def initialize(opts = {})
    @start_date = opts[:start_date]
    @complete_date = opts[:complete_date]
  end

  def lead_time
    Date.strptime(@complete_date, "%d/%m/%Y") - Date.strptime(@start_date, "%d/%m/%Y")
  end

  def to_s
    "Start Date: " + @start_date + ", Complete Date: " + @complete_date
  end
end