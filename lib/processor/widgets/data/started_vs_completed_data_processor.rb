require_relative '../../processor_utils'

module StartedVsCompletedDataProcessor
  include ProcessorUtils

  def process(work_items, configuration = Hash.new)
    @started = Hash.new
    @completed = Hash.new
    populate_keys(work_items)
    populate_values(work_items)
  end

  def output
    send_event(@widget_name, build_output_hash)
  end


  private def populate_keys(work_items)
    items_by_started = order_work_items_by_started(work_items)
    start_date = Date.strptime(items_by_started[0].start_date, WorkItem::DATE_FORMAT)
    first_week = start_date.strftime('%U').to_i
    first_year = start_date.strftime('%Y').to_i

    items_by_completed = order_work_items_by_completed(work_items)
    completed_date = Date.strptime(items_by_completed.last.complete_date, WorkItem::DATE_FORMAT)
    last_week = completed_date.strftime('%U').to_i
    last_year = completed_date.strftime('%Y').to_i

    current_week = first_week.to_i
    current_year = first_year.to_i

    while (current_year<last_year ) || (current_week <= last_week) do
      key = current_year.to_s + "-" + '%02i' % current_week

      @started[key] = 0
      @completed[key] = 0

      if current_week < 52
        current_week+=1
      else
        current_year +=1
        current_week = 1
      end
    end

  end

  private def populate_values(work_items)
    populate_started_values(work_items)
    populate_completed_values(work_items)
  end

  private def populate_completed_values(work_items)
    @completed.keys.each { |key|
      count = 0
      work_items.each { |item|
        if item.complete_week_string == key
          count+=1
        end
      }
      @completed[key] = count
    }
  end

  private def populate_started_values(work_items)
    @started.keys.each { |key|
      count = 0
      work_items.each { |item|
        if item.start_week_string == key
          count+=1
        end
      }
      @started[key] = count
    }
  end

  private def build_labels
    @started.keys
  end

end