# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ =>
  @refresh_seconds = 30
  @refresh_in = @refresh_seconds
  refresh_statuses = =>
    if @allow_refresh
      @refresh_in = @refresh_seconds
      $.ajax
        type: 'GET'
        url: '/home/statuses'
        dataType: 'html'
        success: (data) ->
          if window.last_body_size && window.last_body_size != data.length && window.webkitNotifications.checkPermission() == 0
            nf = window.webkitNotifications.createNotification 'mask.gif', 'DevStatus', 'Development status updates!'
            nf.onshow = ->
              setTimeout( ->
                nf.close()
              5000)
            nf.show()
          window.last_body_size = data.length
          $('#statuses').html data
          $('#last_refresh_status').html('')
        error: (req, type, e) ->
          console.log e
          $('#last_refresh_status').html '(last refresh failed)'

  countdown = =>
    $('#refresh_in').html("#{@refresh_in--}")

  if $('#username').val()?.length
    $('#notice').focus()
  else
    $('#username').focus()

  if window.webkitNotifications.checkPermission() == 1
    $('#notification_permissions').show()
  else
    $('#notification_permissions').hide()

  $('#notification_permissions').click ->
    window.webkitNotifications.requestPermission ->
      $('#notification_permissions').hide()

  @check_refresh = =>
    @allow_refresh = $('#auto_refresh').is(':checked')
    if window.webkitNotifications.checkPermission() == 1
        window.webkitNotifications.requestPermission()
    if @allow_refresh
      @refresh_in = @refresh_seconds
      $('#refresh_label').html('refreshing in')
      $('#refresh_in').html(@refresh_in)
      $('#refresh_unit').html('seconds')
      @status_interval = setInterval refresh_statuses, (@refresh_seconds * 1000)
      @countdown_interval = setInterval countdown, 1000
    else
      $('#refresh_label').add('#refresh_in').add('#refresh_unit').html('')
      clearInterval @status_interval
      clearInterval @countdown_interval

  @check_refresh()
