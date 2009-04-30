Screw.Unit(function() {
  describe("treeView", function() {
    var test_dom;
    before(function() {
      test_dom = document.getElementById('test_dom');
    });

    it("should find the #contents div", function() {
      expect(YAHOO.LQ.contentsDiv()).to(equal, document.getElementById('contents'));
    });
    
    it("should hide the #contents div", function () {
      expect(document.getElementById('contents').style.display).to(equal,'none');
    });
    
    it("should find the subelements of #contents", function () {
      //      expect(YAHOO.LQ.contentsDiv.children).to(equal, document.getElementById('contents'));
      var contents_div = YAHOO.LQ.contentsDiv();
      expect(YAHOO.util.Dom.getChildren(contents_div)).to(equal, YAHOO.util.Dom.getChildren('contents'));
    });

  });
        
  describe("autoComplete", function() {
    });
});

