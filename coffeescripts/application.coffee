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
  console.log command = $('#input-command').val()

  if SpeechSynthesisUtterance?
    u = new SpeechSynthesisUtterance(command)
    u.lang = "zh-TW"

    speechSynthesis.speak(u)

  event.preventDefault()