source = 'http://some.remote.host/bubblechart.xml'

SCHEDULER.every '10s', :first_in => 0 do |job|

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
    },
    {
      label: 'Second dataset',
      data: [
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
        { x: rand(30), y: rand(30), r: rand(5..15) },
      ],
      backgroundColor: '#46BFBD',
      hoverBackgroundColor: '#36A2EB',
    },
  ]

  send_event('bubblechart', { datasets: data })
end
