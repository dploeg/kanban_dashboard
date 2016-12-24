require 'descriptive_statistics'
require 'dashing/app'

class LeadTimeWidgetProcessor

  @percentile_value = -1

  def initialize(percentile = 95)
    @percentile = percentile
  end

  def process(work_items)
    lead_times = Array.new
    work_items.each {
        |item|
      lead_times.push(item.lead_time)
    }

    @percentile_value = lead_times.percentile(@percentile).to_i
  end

  def output
    send_event('lead_times', { items: [label: "Standard Items", value: @percentile_value] })
  end

  def lead_time_95th_percentile
    @percentile_value
  end
end