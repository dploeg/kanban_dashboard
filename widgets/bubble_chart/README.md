# dashing-bubblechart

## Preview

![BubbleChart](https://raw.githubusercontent.com/wiki/jorgemorgado/dashing-bubblechart/bubblechart.png)

## Description

Simple [Dashing](http://shopify.github.com/dashing) widget (and associated job)
to render bubble charts. Uses [Chart.js](http://www.chartjs.org/) library.

## Dependencies

Download the latest v2.x.x release of `Chart.bundle.min.js` from
[https://github.com/chartjs/Chart.js/releases](https://github.com/chartjs/Chart.js/releases)
and copy it into `assets/javascripts`. Make sure to remove any older versions
of Chart.js from the `assets/javascripts` folder.

## Usage

Create the directory `widgets/bubble_chart` and copy this widget's files
into that folder.

Add the following code on the desired dashboard:

```erb
<li data-row="2" data-col="4" data-sizex="1" data-sizey="1">
  <div data-id="bubblechart" data-view ="BubbleChart" data-title="Bubble Chart" data-moreinfo=""></div>
</li>
```

Create your bubble chart job `my_bubblechart_job.rb`:

```ruby
# Note: change this to obtain your chart data from some external source
data = [
  {
    label: 'First dataset',
    data: [
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
    ],
    backgroundColor: '#F7464A',
    hoverBackgroundColor: '#FF6384',
  },
  {
    label: 'Second dataset',
    data: [
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
      { x: rand(30), y: rand(30), r: rand(5..15), },
    ],
    backgroundColor: '#46BFBD',
    hoverBackgroundColor: '#36A2EB',
  },
]
options = { }

send_event('bubblechart', { datasets: data, options: options })
```

### Title Position

By default the title will be displayed in the center of the widget. If you
prefer to move it to the top, change the `$title-position` variable on the
SCSS file. Example:

```scss
$title-position:    top;
```

### Margins

You can also adjust the chart's margins: top, left, right and bottom. By
default they are all 0 (pixels) to use the whole available space. But if
needed you can change their value using the `data-` attributes. Example:

```erb
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div data-id="bubblechart" data-view ="BubbleChart" data-left-margin="5" data-top-margin="10"></div>
</li>
```

If not set, both right and bottom margins will be equal to left and top margins
respectively. This is likely what you want to keep the chart centered within
the widget. If not, set their values also using the `data-` attributes:

```erb
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div data-id="bubblechart" data-view ="BubbleChart" data-right-margin="10" data-bottom-margin="5"></div>
</li>
```

## Contributors

- [Jorge Morgado](https://github.com/jorgemorgado)

## License

This widget is released under the [MIT License](http://www.opensource.org/licenses/MIT).

## Other Chart.js Widgets

- [Bar Chart](https://github.com/jorgemorgado/dashing-barchart)
- [Doughnut Chart](https://github.com/jorgemorgado/dashing-doughnutchart)
- [Line Chart](https://github.com/jorgemorgado/dashing-linechart)
- [Pie Chart](https://github.com/jorgemorgado/dashing-piechart)
- [Polar Chart](https://github.com/jorgemorgado/dashing-polarchart)
- [Radar Chart](https://github.com/jorgemorgado/dashing-radarchart)
