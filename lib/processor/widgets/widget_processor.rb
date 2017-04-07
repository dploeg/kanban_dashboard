
class WidgetProcessor

  def initialize(widget_name)
    @widget_name = widget_name
  end

  def process(work_items, configuration = Hash.new, data = Hash.new)

  end

  def output
    send_event(@widget_name, build_output_hash)
  end

  def build_output_hash()
    Hash.new
  end
end