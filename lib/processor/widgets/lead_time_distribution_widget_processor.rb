class LeadTimeDistributionWidgetProcessor


  def initialize(number_of_labels = 20)
    @num_labels = number_of_labels
  end

  def process(work_items)
    @lead_times = Array.new
    work_items.each { |item|
      @lead_times.push(item.lead_time)
    }
  end

  def output
    send_event('lead_time_distribution', build_output_hash)
  end

  def build_output_hash
    output = Hash.new
    output['labels'] = build_labels
    output['datasets'] = build_datasets
    output['options'] = Array.new
    output
  end

  def build_datasets
    datasets = Array.new
    planned = Hash.new
    planned['label'] = 'Planned'
    planned['data'] = add_lead_time_data
    add_formatting_to_dataset(planned)
    datasets.push(planned)
  end

  def add_lead_time_data
    lead_time_hash = Hash.new
    increment = ((@lead_times.max - @lead_times.min) / @num_labels.to_f).ceil
    for i in 0..@num_labels - 1
      lead_time_hash[(@lead_times.min + i * increment)] = 0
    end


    last_min = -1
    @lead_times.each { |lead_time|
      lead_time_hash.keys.each { |key|
        last_min = key
        break if key.to_i>=lead_time
      }
      lead_time_hash[last_min] = lead_time_hash[last_min] +1
    }

    lead_time_hash.values
  end

  def add_formatting_to_dataset(planned)
    background_colors = Array.new
    border_colors = Array.new
    (0..@num_labels -1).each {
      background_colors.push('rgba(255, 99, 132, 0.2)')
      border_colors.push('rgba(255, 99, 132, 1)')
    }
    planned['backgroundColor'] = background_colors
    planned['borderColor'] = border_colors
    planned['borderWidth'] = 1
  end

  def build_labels()
    labels = Array.new
    increment = ((@lead_times.max - @lead_times.min) / @num_labels.to_f).ceil
    for i in 0..@num_labels - 1
      labels.push(@lead_times.min + i * increment)
    end
    labels
  end

end