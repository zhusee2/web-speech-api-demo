(function() {
  var BaseClass, VoiceAssistant,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.VA = {
    debug: false,
    log: function() {
      if (VA.debug) {
        return console.log(arguments);
      }
    }
  };

  BaseClass = (function() {
    function BaseClass(container) {
      this.container = container;
      this.container = $(this.container);
      if (this.container.length < 1) {
        return false;
      }
    }

    BaseClass.prototype.init = function() {
      return this.bindEvents();
    };

    BaseClass.prototype.bindEvents = function() {};

    return BaseClass;

  })();

  VoiceAssistant = (function(_super) {
    __extends(VoiceAssistant, _super);

    function VoiceAssistant(container) {
      this.container = container;
      VoiceAssistant.__super__.constructor.apply(this, arguments);
      this.fallbacks = {
        recognition: this.container.find('.fallback-recognition')
      };
      this.responseBlock = this.container.find('.response-block');
      this.speakButton = new VoiceAssistant.SpeakButton(this.container.find('#btn-speak'), this);
      this.commandProcessor = new VoiceAssistant.CommandProcessor(this);
      this.responseQueue = [];
      this.speaking = function() {
        if (window.speechSynthesis != null) {
          return window.speechSynthesis.speaking;
        } else {
          return false;
        }
      };
      this.init();
    }

    VoiceAssistant.prototype.init = function() {
      if (window.speechSynthesis != null) {
        return this.bindEvents();
      } else {
        return this.displayFallbackMsg();
      }
    };

    VoiceAssistant.prototype.bindEvents = function() {
      return this.container.on('submit', '.popover .form-recognition', (function(_this) {
        return function(event) {
          var command;
          event.preventDefault();
          VA.log('Form submitted.');
          command = $('#input-command').val();
          _this.commandProcessor.process(command);
          return _this.speakButton.hidePopover();
        };
      })(this));
    };

    VoiceAssistant.prototype.addResponse = function(responseObj) {
      var response;
      response = new VoiceAssistant.Response(responseObj);
      this.responseQueue.push(response);
      if (!this.speaking()) {
        return this.playResponse();
      }
    };

    VoiceAssistant.prototype.playResponse = function() {
      var response, responseDOM;
      if (this.responseQueue.length > 0) {
        VA.log('Ready to play response.');
        response = this.responseQueue.shift();
        responseDOM = response.toDOM();
        this.responseBlock.empty();
        this.responseBlock.append(responseDOM);
        return this.speakResponse($(responseDOM).text());
      }
    };

    VoiceAssistant.prototype.speakResponse = function(responseText) {
      var u;
      VA.log("Speak requested: " + responseText);
      u = new SpeechSynthesisUtterance(responseText);
      u.lang = "zh-TW";
      u.onend = (function(_this) {
        return function(event) {
          VA.log('Utterance Ended.', event);
          return _this.playResponse();
        };
      })(this);
      if (typeof console !== "undefined" && console !== null) {
        console.log(u);
      }
      return window.speechSynthesis.speak(u);
    };

    VoiceAssistant.prototype.displayFallbackMsg = function() {
      return this.responseBlock.find('.fallback-synthesis').removeClass('hide');
    };

    return VoiceAssistant;

  })(BaseClass);

  VoiceAssistant.SpeakButton = (function(_super) {
    __extends(SpeakButton, _super);

    function SpeakButton(container, assistant) {
      this.container = container;
      this.assistant = assistant;
      SpeakButton.__super__.constructor.apply(this, arguments);
      this.init();
    }

    SpeakButton.prototype.init = function() {
      if (window.speechSynthesis != null) {
        this.initPopover();
      }
      return this.bindEvents();
    };

    SpeakButton.prototype.initPopover = function() {
      if (typeof webkitSpeechRecognition === "undefined" || webkitSpeechRecognition === null) {
        return this.container.popover({
          placement: 'top',
          title: 'Speak to me. Not.',
          content: this.assistant.fallbacks.recognition.html(),
          html: true
        });
      }
    };

    SpeakButton.prototype.bindEvents = function() {
      return this.container.on('click', (function(_this) {
        return function(event) {
          if (window.speechSynthesis != null) {
            _this.toggleActive();
          }
          return event.preventDefault();
        };
      })(this));
    };

    SpeakButton.prototype.toggleActive = function() {
      return this.container.toggleClass('active');
    };

    SpeakButton.prototype.hidePopover = function() {
      return this.container.popover('hide');
    };

    return SpeakButton;

  })(BaseClass);

  VoiceAssistant.CommandProcessor = (function(_super) {
    __extends(CommandProcessor, _super);

    function CommandProcessor(assistant) {
      this.assistant = assistant;
      CommandProcessor.__super__.constructor.apply(this, arguments);
    }

    CommandProcessor.prototype.process = function(commandText) {
      if (commandText.match(/書/)) {
        return this.respondToBook();
      }
    };

    CommandProcessor.prototype.respondToBook = function() {
      this.assistant.addResponse({
        text: "好的，正在尋找暢銷書籍⋯⋯"
      });
      return this.assistant.addResponse({
        hiddenText: "我找到了一本好書：丹董的《越吃越享瘦 丹董的爆食減肥法：你不可不吃的 150 家高檔餐廳》。今天有簽書會，要參加嗎？",
        image: "images/cover.jpg"
      });
    };

    return CommandProcessor;

  })(BaseClass);

  VoiceAssistant.Response = (function() {
    function Response(responseObject) {
      this.responseObject = responseObject;
      this.container = $('<div>').addClass('response');
      this.init();
    }

    Response.prototype.init = function() {
      return this.appendResponse();
    };

    Response.prototype.appendResponse = function() {
      var content, type, _ref, _results;
      _ref = this.responseObject;
      _results = [];
      for (type in _ref) {
        content = _ref[type];
        switch (type) {
          case "text":
            _results.push(this.appendText(content));
            break;
          case "hiddenText":
            _results.push(this.appendText(content, "hide"));
            break;
          case "image":
            _results.push(this.appendImage(content));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    };

    Response.prototype.appendText = function(textContent, className) {
      if (className == null) {
        className = "";
      }
      return this.container.append($('<p>').addClass(className).text(textContent));
    };

    Response.prototype.appendImage = function(imageSrc) {
      return this.container.append($('<img>').attr('src', imageSrc));
    };

    Response.prototype.toDOM = function() {
      return this.container.clone();
    };

    return Response;

  })();

  $(function() {
    return VA.instance = new VoiceAssistant('#voice-assistant');
  });

}).call(this);
