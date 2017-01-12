module StartedVsFinishedDataBuilder

  private def add_formatting_to_dataset(data, background, border)
    background_colors = Array.new
    border_colors = Array.new
    (0..@started.length-1).each {
      background_colors.push(background)
      border_colors.push(border)
    }
    data['backgroundColor'] = background_colors
    data['borderColor'] = border_colors
    data['borderWidth'] = 1
  end

  def build_output_hash
    output = Hash.new
    output['labels'] = build_labels
    output['datasets'] = build_datasets
    output['options'] = build_options
    output
  end
end