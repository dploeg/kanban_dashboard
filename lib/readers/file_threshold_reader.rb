class FileThresholdReader

  attr_reader :thresholds

  def initialize(file_name)
    @file_name = file_name
    @thresholds = Hash.new
  end

  def read_thresholds
    file = File.read(@file_name)
    begin
      input_data = JSON.parse(file)
      input_data.each { |input_hash|
        translate_type(input_hash)
        threshold = Threshold.new(input_hash)
        if(@thresholds[threshold.processor].nil?)
          @thresholds[threshold.processor] = Array.new
        end
        @thresholds[threshold.processor].push(threshold)
      }
    rescue => error
      raise RuntimeError.new(error)
    end
    @thresholds
  end

  def translate_type(input_hash)
    unless input_hash["type"].nil?
      input_hash["type"] = Threshold.const_get(input_hash["type"])
    end
  end

end