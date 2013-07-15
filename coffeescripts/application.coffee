$('.btn-speak').on 'click', (event) ->
  $(@).toggleClass('active')
  event.preventDefault()

$('.btn-speak').popover(
  placement: 'top'
  title: 'Speak to me. Not.'
  content: $('.fallback-recognition').html()
  html: true
) if !webkitSpeechRecognition?

$(document).on 'submit', '.form-recognition', (event) ->
  event.preventDefault()