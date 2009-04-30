/*  Dr Nic's JavaScript Test Helpers, version 0.8.0
 *  (c) 2008 Dr Nic Williams
 *
 *  Dr Nic's JavaScript Test Helpers is freely distributable under
 *  the terms of an MIT-style license.
 *  For details, see the web site: http://www.drnicwilliams.com/
 *
 *--------------------------------------------------------------------------*/

var DrNic = DrNic || {};
DrNic.JsTestHelpers = {
  Version: '0.8.0',
};

// from http://code.google.com/p/protolicious/source/browse/trunk/event.simulate.js
Event.simulate = function(element, eventName) {

  var options = {
    pointerX: 0,
    pointerY: 0,
    button: 0,
    ctrlKey: false,
    altKey: false,
    shiftKey: false,
    metaKey: false,
    bubbles: true,
    cancelable: true
  };
  var argumentOptions = arguments[2] || { };
  for (key in arguments) {
    options[key] = arguments[key];
  }

  var eventMatchers = {
    'HTMLEvents': /load|unload|abort|error|select|change|submit|reset|focus|blur|resize|scroll/,
    'MouseEvents': /click|mousedown|mouseup|mouseover|mousemove|mouseout/
  };

  var oEvent, eventType = null;

  for (var name in eventMatchers) {
    if (eventMatchers[name].test(eventName)) eventType = name;
  }

  if (!eventType) throw new SyntaxError('Only HTMLEvents and MouseEvents interfaces are supported; ' +
    eventName + ' not supported');

  element = Test.$(element);
  if (document.createEvent) {
    oEvent = document.createEvent(eventType);
    if (eventType == 'HTMLEvents') {
      oEvent.initEvent(eventName, options.bubbles, options.cancelable);
    }
    else {
      oEvent.initMouseEvent(eventName, options.bubbles, options.cancelable, document.defaultView,
        options.button, options.pointerX, options.pointerY, options.pointerX, options.pointerY,
        options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, element);
    }
    element.dispatchEvent(oEvent);
  }
  else {
    options.clientX = options.pointerX;
    options.clientY = options.pointerY;
    oEvent = Object.extend(document.createEventObject(), options);
    element.fireEvent('on' + eventName, oEvent);
  }
}

Event.simulateMouse = Event.simulate;
Event.simulateHtml = Event.simulate;


// Aliasing Element.simulateMouse(element, eventName) to element._eventName()
if (typeof Prototype != "undefined") {
  (function() {
  	$w('abort blur change error focus load reset resize scroll select submit unload').
  	each(function(eventName){
  		Element.Methods['_' + eventName] = function(element) {
  			element = $(element);
  			Event.simulateHtml(element, eventName, arguments[1] || { });
  			return element;
  		}
  	});

    $w('click dblclick mousedown mousemove mouseout mouseover mouseup contextmenu').
    each(function(eventName){
  		Element.Methods['_' + eventName] = function(element) {
  			element = $(element);
  			Event.simulateMouse(element, eventName, arguments[1] || { });
  			return element;
  		}
  	});
  	Element.addMethods();
  })()
}
Test.Unit.Testcase.prototype.assertDifference = function(expr, fn, count) {
  var orig = eval(expr);
  fn();
  var after = eval(expr);
  this.assertEqual(orig + count, after);
};

Test.Unit.Testcase.prototype.assertNoDifference = function(expr, fn) {
  this.assertDifference(expr, fn, 0);
};

Test.Unit.Testcase.prototype.assertTagDifference = function(selector, fn, count) {
  var expr = "document.getElementsByTagName('" + selector + "').length";
  var orig = eval(expr);
  fn();
  var after = eval(expr);
  this.assertEqual(orig + count, after);
};
// Utility library to allow mocking of prototypejs Ajax.Request calls
// within unit tests.
// Within tests or setup, use like:
// Ajax.Request.setupMock("/url/under/test", function(request, response) {
//   response.responseJSON = "data";
//   request.options.onComplete(response);
// });
var Test = Test || {};
if (typeof Prototype != "undefined") {
  Test.Ajax = Test.Ajax || {};

  Test.Ajax.setupMock = function(url, block) {
    Test.Ajax.prepareMocks();
    Test.Ajax.MockedRequests.set(url, block);
  };

  Test.Ajax.clearMocks = function() {
    Test.Ajax.MockedRequests = $H();
    if (Ajax.Request.prototype.requestOrig) {
      Ajax.Request.prototype.request = Ajax.Request.prototype.requestOrig;
      Ajax.Request.prototype.requestOrig = null;
    }
  };

  Test.Ajax.clearMocks();

  Test.Ajax.prepareMocks = function() {
    if (!Ajax.Request.prototype.requestOrig) {
      Ajax.Request.prototype.requestOrig = Ajax.Request.prototype.request;
      Ajax.Request.prototype.request = function(url) {
        var response = new Ajax.Response(this);
        var request  = this;
        var found    = false;
        Test.Ajax.MockedRequests.each(function(mock) {
          if (!found && url == mock[0]) {
            mock[1](request, response);
            found = true;
          }
        });
        if (!found) {
          return this.requestOrig(url);
        }
      }
    }
  };
}
// Utility library to allow mocking of prototypejs Ajax.Request calls
// within unit tests.
// Within tests or setup, use like:
// Test.Ajax.setupMock("/url/under/test", function(request, response) {
//   response = "data";
//   request.complete(response);
// });
var Test = Test || {};
Test.Ajax = Test.Ajax || {};
if (typeof jQuery != "undefined") {
  (function($){

    Test.Ajax.setupMock = function(url, block) {
      Test.Ajax.prepareMocks();
      Test.Ajax.MockedRequests[url] = block;
    };

    Test.Ajax.clearMocks = function() {
      Test.Ajax.MockedRequests = {};
      if ($.ajaxOrig) {
        $.ajax = $.ajaxOrig;
        $.ajaxOrig = null;
      }
    };

    Test.Ajax.clearMocks();

    Test.Ajax.prepareMocks = function() {
      if (!$.ajaxOrig) {
        $.ajaxOrig = $.ajax;
        $.ajax = function(options) {
          var response = {};
          var found    = false;
          for (var url in Test.Ajax.MockedRequests) {
            var mock = Test.Ajax.MockedRequests[url];
            if (!found && mock) {
              mock(options, response);
              found = true;
            }
          };
          if (!found) {
            return $.ajaxOrig(options);
          }

        };
      }
    };

  })(jQuery);
}