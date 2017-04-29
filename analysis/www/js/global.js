jQuery(document).ready(function($) {
	
	var pageClass = $("html").attr("class");

	/* 
	 * Insert containers for javascript dependent visualisations
	 */
	if (pageClass == "game") {
		$("main > section").filter(":first").before("<section class=\"network\"><h2 id=\"network\">Network</h2><div id=\"vis1\" class=\"network-visualisation\"/></section>");
		$("main > .contents li").filter(":first").before("<li><a href=\"#network\">Network</a></li>");
		$("main > section.tickets > section").filter(":first").after("<section><h3 id=\"ticket-distribution\">Distribution</h3><div id=\"vis2\" class=\"network-visualisation\"/></section>");	 	
	};

	/* 
	 * Reorganise the content into tabbed containers
	 */
	 var Tab = function tab(containerElement, labelElement, keyIn, parent) {
	 	
	 	this.key = keyIn;
	 	this.container = containerElement;
	 	this.label = labelElement;
	 	this.tabs = parent;
	 	
	 	this.getId = function(){
	 		return $(this.container).find("> h2, > h3").attr("id");
	 	};
	 	
	 	this.getContainer = function(){
	 		return this.container;
	 	}
	 	
	 	this.show = function(){
	 		$(this.container).add(this.label).addClass("focus");
	 	};
	 	this.hide = function(){
	 		$(this.container).add(this.label).removeClass("focus");
	 	};
	 	
	 	this.init = function(hasFocus){
	 		
	 		var self = this;
			
	 		$(this.container, this.label).addClass("tab");
			
			$(this.label).on("click", function(){
				self.tabs.show(self.key);
			});
			 	 		
 	 		if (hasFocus) {
 	 			this.show();
 	 		} else {
 	 			this.hide();
 	 		};
 	 		
 	 		/* 
	 		 * Find content that should be organised into
	 		 * sub-tabs and create those sub-tabs.
	 		 */
	 		if ($(this.container).find(" > section").length > 0) {
	 		    
	 		     /*
	 		      * Subsections found.
	 		      * Process this tab as a collection of tabbed content
	 		      */ 
	 		     var subTabs = new Tabs($(this.container));
    	 		 
    	 		 var subTabsContainer = this.container;
    	 		 
    	 		 // Create a contents list from the subsection headings.
    	 		 var subsectionHeadings = [];
    	 		 var subsectionIds = [];
                 $(subTabsContainer).find(" > section > h3").each(function(){
                    subsectionHeadings.push($(this).text());
                    subsectionIds.push($(this).attr("id"));
                 }); 
                
                 $(subTabsContainer).find(" > h2").after("<div class=\"contents\"><h3 class=\"heading\">Contents</h3><nav><ul></ul></nav></div>");
                 for (var i = 0; i < subsectionHeadings.length; i++) {
                     $(subTabsContainer).find(" > .contents ul").append("<li><a href=\"#" + subsectionIds[i] + "\">" + subsectionHeadings[i] + "</a></li>");
                 };
                 
                 // Create a tab from each subsection.
                 $(subTabsContainer).find(" > .contents li").each(function(){
                	var i = $(this).prevAll().length;
                 	subTabs.createTab($(subTabsContainer).find(" > section").eq(i), this);
                 }); 
    	 		
    	 		// Initialise this collection of sub-tabs.
            	subTabs.init();
            	
	 		};
 	 		
		};
		
	 };
	 
	 var Tabs = function tabs(containerElement) {
	 	
	 	this.collection = new Array();
	 	this.container = containerElement;
	 	this.length = this.collection.length;
	 	
	 	this.getContainer = function(){
	 		return this.container;
	 	};
	 	
	 	this.getId = function(){
	 		return $(this.container).find("> h2, > h3").attr("id");
	 	};
	 	
	 	this.createTab = function(containerElement, labelElement){
	 		this.collection.push(new Tab(containerElement, labelElement, this.collection.length + 1, this));
	 	};
	 	
	 	this.show = function(key) {
	 		for (var i = 0; i < this.collection.length; i++) {
	 			this.collection[i].hide();
	 		};
	 		for (var i = 0; i < this.collection.length; i++) {
	 			var tab = this.collection[i];
	 			if (tab.key == key) {
	 				tab.show();
	 			};
	 		};
	 		showHide.fire();
	 	};
	 	
	 	this.containsTab = function(bookmarkId) {
	 		if ($(this.container).find(bookmarkId).length > 0) {
	 			return true;
	 		}
	 		return false;
	 	};

		var shouldHaveFocus = function(self) {
		
			var bookmarkId = window.location.hash;
	 		var bookmark;
	 		if (bookmarkId.length > 0 && bookmarkId.substr(0, 1) == "#") {
	 			bookmark = bookmarkId.substr(1);
	 		} else {
	 			bookmarkId = "";
	 			bookmark = "";
	 		};
	 		
	 		var containerHasFocus = (bookmark.length > 0 && self.getId() == bookmark);
	 		var containerAncestorHasFocus = (bookmark.length > 0 && $(self.container).parents(bookmarkId).length > 0);
	 		var containerDescendantHasFocus = (bookmark.length > 0 && $(self.container).find(bookmarkId).length > 0);
	 		
	 		for (var i = 0; i < self.collection.length; i++) {
	 			
	 			var tabId = self.collection[i].getId();	 			
	 			
	 			var hasFocus;
	 			if (((bookmark.length < 1 || containerHasFocus) && i == 0) || (containerDescendantHasFocus && tabId == bookmark)) {
	 				return i;
	 			} else if (containerDescendantHasFocus && $(self.collection[i].getContainer()).find(bookmarkId).length > 0) {	 				
	 				return i;	
	 			} 
	 			
	 		};
	 		return 0;
		};

	 	this.init = function(){
	 	
	 		var focusOnTab = shouldHaveFocus(this); 
	 		
	 		for (var i = 0; i < this.collection.length; i++) {			
	 			
	 			var hasFocus;
	 			if (i == focusOnTab) {
	 				hasFocus = true;	
	 			} else {
	 				hasFocus = false;
	 			};
	 			this.collection[i].init(hasFocus);
	 		};
	 		
            var container = this.container;
	 		$(container).addClass("tabbed");
	 		
	 	};
	 	
	 };
	 
	 // Convert each of the main sections into tabs (tabbed content).
	 var mainTabs = new Tabs($("main"));
	 $("main > .contents li").each(function(){
	 	var i = $(this).prevAll().length;
	 	mainTabs.createTab($("main > section").eq(i), this);
	 });
	 mainTabs.init();
	
	generateVisualisations($);
	
});