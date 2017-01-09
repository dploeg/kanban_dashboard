
class ControlChartWidgetProcessor


  def process(work_items)
    @lead_times = Array.new
    ordered_work_items = order_work_items(work_items)
    ordered_work_items.each { |item|
      @lead_times.push(item.lead_time)
    }
  end

  def output
    send_event('control_chart', build_output_hash)
  end

  def build_output_hash
    output = Hash.new

    data = build_data
    output['datasets'] = [{:label => "Standard", :data => data, :backgroundColor => "#F7464A", :hoverBackgroundColor => "#FF6384"}]

    options= {
            scales: {
                xAxes: [{
                    ticks: {
                        beginAtZero: true,
                        stepSize: 1.0
                    }
                }],
                yAxes: [{
                    ticks: {
                        beginAtZero: true,
                        fixedStepSize: 1.0
                    }
                }]
            }
        }
    output['options'] = options
=begin
    data = [
        {
          label: 'First dataset',
          data: [
            { x: rand(30), y: rand(30), r: rand(5..15) },
            { x: rand(30), y: rand(30), r: rand(5..15) },
            { x: rand(30), y: rand(30), r: rand(5..15) },
            { x: rand(30), y: rand(30), r: rand(5..15) },
            { x: rand(30), y: rand(30), r: rand(5..15) },
          ],
          backgroundColor: '#F7464A',
          hoverBackgroundColor: '#FF6384',
        }
      ]
    output['datasets'] =  data

=end

    output
  end

  private def order_work_items(work_items)
    work_items.sort { |a,b|  Date.strptime(a.complete_date, '%d/%m/%Y') <=> Date.strptime(b.complete_date, '%d/%m/%Y')}
  end

  private def build_data
    data = Array.new

    x_counter = 1
    @lead_times.each {
        | lead_time |
      data.push({:x => x_counter, :y => lead_time, :r =>5})
      x_counter = x_counter + 1
    }
    data
  end


      # {"datasets"=>[{:label=>"First dataset", :data=>[{:x=>11, :y=>23, :r=>10}, {:x=>21, :y=>17, :r=>11}, {:x=>17, :y=>24, :r=>6}, {:x=>14, :y=>27, :r=>11}, {:x=>10, :y=>18, :r=>10}], :backgroundColor=>"#F7464A", :hoverBackgroundColor=>"#FF6384"}]}
      # {"datasets"=>[{:label=>"Standard", :data=>[{:x=>0, :y=>11, :r=>1}, {:x=>1, :y=>6, :r=>1}, {:x=>2, :y=>6, :r=>1}, {:x=>3, :y=>12, :r=>1}, {:x=>4, :y=>13, :r=>1}, {:x=>5, :y=>9, :r=>1}], :backgroundColor=>"#F7464A", :hoverBackgroundColor=>"#FF6384"}]}

end