jQuery(document).ready(function($) {
	
	var pageClass = $("html").attr("class");

	/* 
	 * Insert containers for javascript dependent visualisations
	 */
	if (pageClass == "game") {
		$("main > section").filter(":first").before("<section id=\"network\" class=\"network\"><h2>Network</h2><div id=\"vis1\" class=\"network-visualisation\"/></section>");
		$("main > .contents li").filter(":first").before("<li>Network</li>");
		$("main > #tickets > section").filter(":first").after("<section id=\"ticket-distribution\"><h3>Distribution</h3><div id=\"vis2\" class=\"network-visualisation\"/></section>");	 	
	};

	/* 
	 * Reorganise the content into tabbed containers
	 */
	 var Tab = function tab(containerElement, labelElement, keyIn, parent) {
	 	
	 	this.key = keyIn;
	 	this.container = containerElement;
	 	this.label = labelElement;
	 	this.tabs = parent;
	 	
	 	this.show = function(){
	 		$(this.container).add(this.label).addClass("focus");
	 	};
	 	this.hide = function(){
	 		$(this.container).add(this.label).removeClass("focus");
	 	};
	 	
	 	this.init = function(hasFocus){
	 		
	 		var self = this;
  			$(this.label).find("a").each(function(){
				$(this).replaceWith(this.childNodes);	
			});
			
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
   	             console.log("Current tab: ", subTabs);   
    	 		 
    	 		 var subTabsContainer = this.container;
    	 		 
    	 		 // Create a contents list from the subsection headings.
    	 		 var subsectionHeadings = [];
                 $(subTabsContainer).find(" > section > h3").each(function(){
                    subsectionHeadings.push($(this).text());
                 }); 
                 $(subTabsContainer).find(" > h2").after("<div class=\"contents\"><h3 class=\"heading\">Contents</h3><nav><ul></ul></nav></div>");
                 for (var i = 0; i < subsectionHeadings.length; i++) {
                     $(subTabsContainer).find(" > .contents ul").append("<li>" + subsectionHeadings[i] + "</li>");
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
	 	
	 	this.init = function(){
	 	
	 		for (var i = 0; i < this.collection.length; i++) {
	 			var hasFocus;
	 			if (i == 0) {
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