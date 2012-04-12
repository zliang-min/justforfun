# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  tweet_field = $ 'form textarea'
  tweet_field.focus()
  $('form').live 'ajax:success', (event, data) ->
    $('<li>' + data.body + '</li>').prependTo $('#tweets')
    tweet_field.val('').focus()
