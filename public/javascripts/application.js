
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
YAHOO.namespace( 'LQ' ); // LQ = LiveQuery
YAHOO.LQ = function(){
  var $C = YAHOO.util.Connect,
  $E = YAHOO.util.Event,
  $D = YAHOO.util.Dom,
  $ = $D.get,
  $W = YAHOO.widget;
  
  var dataSchema = ['result','title','docid'],
  queryInputId = 'live_query',
  resultsContainerId = 'live_results',
  searchUrl = '/helptool/search',
  docUrl = '/helptool/docs/',
  extraParams = 'livequery=1',
  contentsId = 'contents',
  treeviewDiv = 'contents_treeview',
  docTextDiv = 'doc_text',
  searchSubmitId = 'search_submit',
  kbLinkClass = 'kblink',
  tvLinkClass = 'ygtvlabel',
  searchFormId = 'search',
  maxResultsInContainer = 4,
  ACSeeAllLinkClass = 'ACSeeAll',
  resultsDiv = 'results';
  
  var autoCompleteConfig = {
    autoHighlight: false,
    animVert: true,
    animHoriz: false,
    animSpeed: 0.1,
    minQueryLength: 4,
    useShadow: true,
    prehighlightClassName: "yui-ac-prehighlight",
    maxResultsDisplayed: maxResultsInContainer
  };
    
  return {

    contentsDiv : function() {
      return $(contentsId);
    },

    contentsDivChildren : function () {
      return $D.getChildren(YAHOO.LQ.contentsDiv());
    },

    init : function() {
      YAHOO.LQ.initAutoCompleteWidget();
      YAHOO.LQ.initTreeViewWidget();
    },

    initAutoCompleteWidget : function() {

      //My dataSchema for the autoComplete widget
      var myDataSource = new $W.DS_XHR(searchUrl, dataSchema);
      myDataSource.responseType = $W.DS_XHR.TYPE_XML;
      //
      // I can't get Rails to respond to the Accept header that this sets
      //     this.myDS.connMgr.initHeader('Accept','application/xml');
      // so instead of setting the header we append a param to tell the backend
      // to return xml instead of html
      myDataSource.scriptQueryAppend = extraParams;
      var myAutoComplete = new $W.AutoComplete(
        queryInputId,
        resultsContainerId,
        myDataSource,
        autoCompleteConfig
        );
      
      var itemSelectListener = function(sType, args) {
        // sType is a string giving the type of event, in this case, 'itemSelect'
        var oAC = args[0], //the autocomplete instance
        elSelected = args[1], //the selected li element
        aData = args[2]; //the data object converted into an array using my dataSchema
        //this line works around Opera's preventDefault bug:
        $(searchSubmitId).disabled = true;
        // for info on the structure of aArgs, see
        // http://www.insideria.com/2008/05/writing-your-first-yui-applica.html
        var docid = aData[1];
        YAHOO.LQ.retrieveAndUpdate(docUrl + docid, docTextDiv)
      };

      // wire up the itemSelectListener to the AutoComplete instance's itemSelectEvent
      myAutoComplete.itemSelectEvent.subscribe(itemSelectListener);

      var createFooterWithNumberOfResults = function(sType, args) {
        var oSelf = args[0],
        sQuery = args[1],
        aResults = args[2];
        var numResults = aResults.length;
        YAHOO.log(numResults > maxResultsInContainer);
        //      if (numResults > maxResultsInContainer) {
        oSelf.setFooter("<a id='show_all' class='"+ ACSeeAllLinkClass +"' href='#'>"+ numResults +" search results.</a>");
      //     }
      };
      // show how many results you got in the footer of the container
      myAutoComplete.dataReturnEvent.subscribe(createFooterWithNumberOfResults);
      // suppress the standard behavior by overriding a private method on
      // this specific AutoComplete instance so it doesn't update the input field text:
      myAutoComplete._updateValue = function() {
        return true;
      };
    /* We want to have, at the bottom of the search container, a
   link making it obvious to the user how s/he can find *all*
   results for the current query.  We'll use AutoComplete's
   built-in footer mechanism for that, adding a link to which
   we'll wire a form-submit event: */

    // Here's the wiring for the form submission on our footer link.
    //      $E.on('show_all', 'click', function(e) {
    //      $(searchFormId).submit();
    //  });
    },
    
    querySubmitListener : function (e) {
      var searchForm = $(searchFormId);
      var query= searchForm.live_query.value;
      var url = searchForm.action;
      url += '?query=' + query;
      YAHOO.LQ.retrieveAndUpdate(url, resultsDiv)
      $E.stopEvent(e);
    },

    //initTreeViewWidget loads the <ul> in the contents doc into a YAHOO!
    //TreeView widget
    initTreeViewWidget : function() {
      //hide the regular contents div
      var contents = YAHOO.LQ.contentsDiv();
      contents.style.display = 'none';
      var elements = YAHOO.LQ.contentsDivChildren();
      var contentsTree = new $W.TreeView(treeviewDiv);
      YAHOO.LQ.buildTreeRecursively(contentsTree.getRoot(), elements);
      contentsTree.draw();
    },

    //buildTreeRecursively walks the tree of the nested <ul>s and
    //creates the TreeView nodes
    buildTreeRecursively : function(root, elements) {
      var element = elements.shift();
      //last leaf, we're done with this branch
      if (!element) {
        return;
      }
      var children = $D.getChildren(element);
      if (element.nodeName.toUpperCase() == 'UL') {
        //build new subtree off this element
        YAHOO.LQ.buildTreeRecursively(root, children)
      }
      else if (element.nodeName.toUpperCase() == 'LI') {
        //the first child of a LI should always be an <a> whether this
        //is a heading node or a doc node
        var link = children.shift();
        // the below conditional with short-circuiting for a null href
        // attr should still work once I drop the empty anchors in the
        // headings of the contents doc
        if (link.href && link.href != '') {
          //this is a link to a doc so use it to create a TextNode
          //TextNodes accept a configuration object that you can use
          //to set label, href, and class. I'm setting class='kblink'
          //in order to leverage the ajax link retriever I've already
          //written for kbas and kbhs.
          var config = {
            label: link.innerHTML,
            href: link.href,
            className: kbLinkClass
          };
          new $W.TextNode(config,root,false);
        }
        else {
          //we know this is a menu node since it (right now) is an <a> element
          //with no href attr. I want to change these in the future to be just
          //<h3>s or something simpler. They have to be <a>s now to make
          //aq3treeclickable work to build the tree
          var subMenu = new $W.MenuNode(link.textContent,root,false)
          YAHOO.LQ.buildTreeRecursively(subMenu,children)
        }
      }
      //the fall-though call, progressing down the doc to the next element
      YAHOO.LQ.buildTreeRecursively(root,elements);
    },
  
    // listen for clicks on kblinks and get them via ajax
    kbLinkClickListener : function (e) {
      var elTarget = $E.getTarget(e);
      if (elTarget.nodeName.toUpperCase() == 'A') {
        //the links generated by the Treeview widget are also to kbdocs, so check for the classname
        // that it adds also.
        if ($D.hasClass(elTarget,kbLinkClass) || $D.hasClass(elTarget,tvLinkClass)) {
          var url = elTarget.href;
          YAHOO.LQ.retrieveAndUpdate(url, docTextDiv);
          $E.stopEvent(e);
        }
        if ($D.hasClass(elTarget,ACSeeAllLinkClass)) {
         $(searchFormId).submit();
        }
      }
    },

    // set up a listener function for ajax doc retrieval when a doc is
    // selected in the ajax drop down or through a kblink
    retrieveAndUpdate : function(url, el) {
      $C.asyncRequest('GET', url, YAHOO.LQ.updater(el));
    },

    // set up a callback object to update the doc_text div
    updater : function(el){
      return {
        success : function(o) {
          $(el).innerHTML = o.responseText;
        },
        failure : function(o) {}
      };
    }
  }
}();
YAHOO.widget.Logger.enableBrowserConsole();
YAHOO.util.Event.onDOMReady(YAHOO.LQ.init);
// install our kblink listener on the body element and wait for a
// kblink click.  Delegating like this is more efficient than
// attaching a handler to each kblink as well as automatically working
// on dynamic DOM elements
YAHOO.util.Event.on('body', 'click', YAHOO.LQ.kbLinkClickListener);
// listen to the search form and submit via AJAX
YAHOO.util.Event.on('search', 'submit', YAHOO.LQ.querySubmitListener);

