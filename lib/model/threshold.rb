
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


end