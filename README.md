The Kanban dashboard is intended to be a way for teams & organisations to visualise the data captured from their Kanban system.
There are two key pieces of information used for generating the visualisations - the start and end date per ticket / work item.

There are two existing github projects that this work is based on:
  
  - Dashing (AKA [Smashing](https://github.com/Smashing/smashing)) – this is a dashboard that a number of teams use to 
  put up all kinds of operational information on big screens in their offices. This project is built on an instance of 
  a Smashing Dashboard. 
  
  - Focused Objective’s [excel sheets](https://github.com/FocusedObjective/FocusedObjective.Resources). Many of the charts
  displayed are based upon those that are available here. 


You can customise this by writing custom adapters so that you can read this data from your particular electronic kanban system - 
so long as there is a way to access the data (eg an API) then you should be able to pull data into the system.

## Key features 


<li><b>Thresholds</b></li>

Given that it’s a dashboard what is important is to have a quick, visual way to alert us to problems. 
The “Threshold” has been created to serve this purpose - it is basically an upper or lower control limit that you can apply 
against a particular type of data. This could potentially be what is negotiated with leaders who can get alerted to problems.
Custom thresholds can be written and added to the base suite. 

<li><b>Source data Adapters</b></li>

The basic scenario uploaded reads info from files located in the assets subdirectory, its just looking for a 
started and completed date per ticket but Class of Service has been added as an optional field. 
This has been written in such a way that we can potentially hook this up to any ALM tool with web service interfaces 
\- we just need to write an adapter to read out the information from the particular source. A very basic one for Jira is 
all that exists so far.
 

## Technical stuff
 
The <code>dashboard.rb</code> file is where all of the items are wired in together. Note, presently this is set to 10 seconds to aid development, however for deployment you may want to set this higher (say every 5-10 minutes). 
Date format is currently set to <code>%d/%m/%y</code>. If you wish to change this, please refer to the constant <code>WorkItem::DATE_FORMAT</code>

### Starting the application 
Once you've cloned the repository, start the smashing dashboard:

<code>smashing start</code>

Point your browser to <code>localhost:3030</code> and the default dashboard will be displayed. At present, there are 3 dashboards:

<ul>
<li><code>localhost:3030/dashboard</code>  - dumping group for all charts used for development</li>
<li><code>localhost:3030/lead_times</code> - A collection of lead time charts</li>
<li><code>localhost:3030/flow</code> - A collection of flow based charts</li> 
</ul>
 
### Customising your view
In the <code>dashboards</code> folder there are a series of erb files with the views in them. If you wanted to create your own
 construct another file with the same layout as the existing files (the smashing layout for views)

### Implementing a new Threshold
Have a look in the <code>lib/processor/threshold</code> folder for examples. You will need to create a new threshold class and implement the <code>process(work_items, *thresholds)</code> function.
Make sure to name the threshold when its initialized(this is how it matches the threshold configuration to the class)
Once you've done that, configure the thresholds in the <code>assets/dashboard_data/thresholds.json</code> folder.
 

### Implementing a new widget / graph
Have a look in the <code>lib/processor/widgets</code> folder for examples. You will need to create a new <code>WidgetProcessor</code> (subclass) class and implement:

<ul>
 <li><code>process(work_items, configuration = Hash.new)</code></li>
 <li><code>build_output_hash</code></li>
</ul>

 
Make sure to name the widget when its initialized(this is how it matches the widget in <code>dashboard.erb</code> to the class)
Once you've done that, add the widget to the <code>dashboard.erb</code> folder.
If your processor needs configurations add the to the <code>assets/dashboard_data/dashboard_config.yaml</code>

### Implementing a new source data adapter
Have a look in the <code>lib/readers/work_item</code> folder for examples. You will need to create a new reader class to access items from alternate data sources.
Create your own work item reader and implement the <code>read_data</code> function.   

### Wiring it together
When you've implemented your alternate implementations, you can wire them in with the <code>dashboard.rb</code> file.
        
 
## License
 
Distributed under the [MIT license](License.txt).
 
Smashing is distributed under [MIT license](https://github.com/Smashing/smashing/blob/master/MIT-LICENSE)
