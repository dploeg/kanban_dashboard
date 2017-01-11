class Dashing.List extends Dashing.Widget
  ready: ->
    if @get('unordered')
      $(@node).find('ol').remove()
    else
      $(@node).find('ul').remove()


  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i, c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"