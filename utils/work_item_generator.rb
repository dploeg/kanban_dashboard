require 'json'
require 'simple-random'
require_relative '../lib/model/work_item'


def determine_class_of_service()
  # classes_of_service_rates = {EXPEDITE => 10, STANDARD => 60, FIXED_DATE => 20, INTANGIBLE => 10}
  random = rand(1..10)
  class_of_service = case random
                       when 1
                         EXPEDITE
                       when 2..7
                         STANDARD
                       when 8..9
                         FIXED_DATE
                       when 10
                         INTANGIBLE
                     end
  class_of_service
end

def get_complete_date_additional_days(class_of_service, classes_of_service_max_days)
  r = SimpleRandom.new
  r.set_seed
  classes_of_service_max_days[class_of_service] * r.weibull(2,4) /10
end

num_items = 100

first_date = DateTime.strptime("1/1/16", WorkItem::DATE_FORMAT)
last_date = DateTime.strptime("30/6/16", WorkItem::DATE_FORMAT)

puts "First date: " + first_date.strftime(WorkItem::DATE_FORMAT)
puts "Last date: " + last_date.strftime(WorkItem::DATE_FORMAT)
EXPEDITE = "Expedite"
STANDARD = "Standard"
FIXED_DATE = "Fixed Date"
INTANGIBLE = "Intangible"

classes_of_service_max_days = {EXPEDITE => 10, STANDARD => 42, FIXED_DATE => 30, INTANGIBLE => 50}

work_items = Array.new
item_count = 0

(0..num_items).each {
  class_of_service = determine_class_of_service


  start_date = rand(first_date..last_date)
  complete_date = rand(start_date..start_date+get_complete_date_additional_days(class_of_service, classes_of_service_max_days))

  work_items.push(WorkItem.new(:start_date => start_date.strftime(WorkItem::DATE_FORMAT), :complete_date => complete_date.strftime(WorkItem::DATE_FORMAT), :class_of_service => class_of_service))
  item_count+=1
}

work_items.each {|item|
  puts item.to_s
}

File.open("generated_work_items.json", "w") do |f|
  f.write(work_items.to_json)
end


