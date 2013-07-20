window.VA = {
  debug: false
  log: -> console.log arguments if VA.debug
}

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
    @responseQueue = []
    @speaking = ->
      if window.speechSynthesis?
        window.speechSynthesis.speaking
      else
        false

    @init()

  init: ->
    if window.speechSynthesis?
      @bindEvents()
    else
      @displayFallbackMsg()

  bindEvents: ->
    @container.on 'submit', '.popover .form-recognition', (event) =>
      event.preventDefault()
      VA.log('Form submitted.')

      command = $('#input-command').val()
      @commandProcessor.process(command)
      @speakButton.hidePopover()


  addResponse: (responseObj) ->
    response = new VoiceAssistant.Response(responseObj)
    @responseQueue.push response

    @playResponse() if not @speaking()

  playResponse: ->
    if @responseQueue.length > 0
      VA.log 'Ready to play response.'

      response = @responseQueue.shift()
      responseDOM = response.toDOM()

      @responseBlock.empty()
      @responseBlock.append(responseDOM)

      @speakResponse $(responseDOM).text()

  speakResponse: (responseText) ->
    VA.log("Speak requested: #{responseText}")

    u = new SpeechSynthesisUtterance(responseText)
    u.lang = "zh-TW"

    u.onend = (event) =>
      VA.log 'Utterance Ended.', event
      @playResponse()

    # Workaround for that SpeechSynthesisEvent will not be fired if it's
    # never logged to console in WebKit Nightly (since r152754.)
    console.log u if console?

    window.speechSynthesis.speak(u)

  displayFallbackMsg: ->
    @responseBlock.find('.fallback-synthesis').removeClass('hide')


class VoiceAssistant.SpeakButton extends BaseClass
  constructor: (@container, @assistant) ->
    super
    @init()

  init: ->
    @initPopover() if window.speechSynthesis?
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
      @toggleActive() if window.speechSynthesis?
      event.preventDefault()

  toggleActive: ->
    @container.toggleClass('active')

  hidePopover: ->
    @container.popover('hide')


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
    @assistant.addResponse(
      hiddenText: "我找到了一本好書：丹董的《越吃越享瘦 丹董的爆食減肥法：你不可不吃的 150 家高檔餐廳》。今天有簽書會，要參加嗎？",
      image: "images/cover.jpg"
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
  VA.instance = new VoiceAssistant('#voice-assistant')
