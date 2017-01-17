require 'YAML'

class FileConfigReader

  def initialize(filename)
    @filename = filename
  end

  def read_config
    begin
      config = YAML.load_file(@filename)
    rescue => error
      raise RuntimeError.new(error)
    end

    unless config
      return Hash.new
    end
    config
  end
end