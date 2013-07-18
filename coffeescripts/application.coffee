class BaseClass
  constructor: (@container) ->
    @container = $(@container)
    return false if @container.length < 1

  init: ->
    @bindEvents()

  bindEvents: ->


class VoiceAssistant extends BaseClass
  constructor: (@container) ->
    super

    @fallbacks = {
      recognition: @container.find('.fallback-recognition')
    }
    @speakButton = new VoiceAssistant.SpeakButton @container.find('#btn-speak'), @

    @init()

  init: ->
    @bindEvents()

  bindEvents: ->
    @container.on 'submit', '.popover .form-recognition', (event) ->
      command = $('#input-command').val()

      if SpeechSynthesisUtterance?
        u = new SpeechSynthesisUtterance(command)
        u.lang = "zh-TW"

        speechSynthesis.speak(u)

      event.preventDefault()

class VoiceAssistant.SpeakButton extends BaseClass
  constructor: (@container, @assistant) ->
    super
    @init()

  init: ->
    @initPopover()
    @bindEvents()

  initPopover: ->
    @container.popover(
      placement: 'top'
      title: 'Speak to me. Not.'
      content: @assistant.fallbacks.recognition.html()
      html: true
    ) if !webkitSpeechRecognition?

  bindEvents: ->
    @container.on 'click', (event) =>
      @toggleActive()
      event.preventDefault()

  toggleActive: ->
    @container.toggleClass('active')



class VoiceAssistant.Response
  constructor: (@responseObject) ->
    @container = $('<div>').addClass('response')
    @init()

  init: ->
    @addResponse()

  appendResponse: ->
    for type, content of @responseObject
      switch type
        when "text" then @appendText(content)
        when "image" then @appendImage(content)

  appendText: (textContent) ->
    @container.append $('<p>').text(textContent)

  appendImage: (imageSrc) ->
    @container.append $('<img>').attr('src', imageSrc)

$ ->
  window.va = new VoiceAssistant('#voice-assistant')
