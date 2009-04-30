YAHOO.namespace('FIXTURES');
Screw.Unit(function() {
  before(function() {
    var test_dom = document.getElementById('test_dom');
    // initialize TEST_DOM
    YAHOO.FIXTURES.TEST_DOM = YAHOO.FIXTURES.TEST_DOM || test_dom;
    // overwrite div.test_dom with TEST_DOM, effectively resetting it between tests
//    test_dom.innerHTML = YAHOO.FIXTURES.TEST_DOM.innerHTML;
  });
});