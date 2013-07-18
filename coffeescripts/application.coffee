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
    @responseBlock = @container.find('.response-block')
    @speakButton = new VoiceAssistant.SpeakButton @container.find('#btn-speak'), @
    @commandProcessor = new VoiceAssistant.CommandProcessor @

    @init()

  init: ->
    @bindEvents()

  bindEvents: ->
    @container.on 'submit', '.popover .form-recognition', (event) =>
      event.preventDefault()

      command = $('#input-command').val()
      @commandProcessor.process(command)


  addResponse: (responseObj) ->
    response = new VoiceAssistant.Response(responseObj)
    @responseBlock.append response.toDOM()

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


class VoiceAssistant.CommandProcessor extends BaseClass
  constructor: (@assistant) ->
    super

  process: (commandText) ->
    if commandText.match(/書/)
      @respondToBook()

  respondToBook: ->
    @assistant.addResponse(
      text: "好的，正在尋找暢銷書籍⋯⋯"
    )

class VoiceAssistant.Response
  constructor: (@responseObject) ->
    @container = $('<div>').addClass('response')
    @init()

  init: ->
    @appendResponse()

  appendResponse: ->
    for type, content of @responseObject
      switch type
        when "text" then @appendText(content)
        when "hiddenText" then @appendText(content, "hide")
        when "image" then @appendImage(content)

  appendText: (textContent, className = "") ->
    @container.append $('<p>').addClass(className).text(textContent)

  appendImage: (imageSrc) ->
    @container.append $('<img>').attr('src', imageSrc)

  toDOM: ->
    @container.clone()

$ ->
  window.va = new VoiceAssistant('#voice-assistant')
