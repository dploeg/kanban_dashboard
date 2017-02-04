
class Threshold

  UPPER = "Upper Control Limit"
  LOWER = "Lower Control Limit"
  DIFF = "Difference"

  attr_accessor :type, :value, :processor, :class_of_service

  def initialize(args)
    @type = UPPER
    args.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def ==(other)
    self.type == other.type && self.value == other.value && self.processor == other.processor && self.class_of_service == other.class_of_service
  end

  def to_s
    "Threshold(Type: #{@type}, value: #{@value}, class_of_service: #{@class_of_service}, processor: #{@processor}, object_id: #{"0x00%x" % (object_id << 1)})"
  end

end