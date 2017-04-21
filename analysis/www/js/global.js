jQuery(document).ready(function($) {
	
	var pageClass = $("html").attr("class");

	/* 
	 * Insert containers for javascript dependent visualisations
	 */
	if (pageClass == "game") {
		$("main > section").filter(":first").before("<section id=\"network\" class=\"network\"><h2>Network</h2><div id=\"vis1\" class=\"network-visualisation\"/></section>");
		$("main > .contents li").filter(":first").before("<li>Network</li>");
		$("main > #tickets > section").filter(":first").before("<section id=\"ticket-distribution\"><h3>Distribution</h3><div id=\"vis2\" class=\"network-visualisation\"/></section>");	 	
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
 	 		}
		};
		
	 };
	 
	 var Tabs = function tabs(containerElement) {
	 	
	 	this.collection = new Array();
	 	this.container = containerElement;
	 	
	 	this.length = this.collection.length;	
	 	
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
	 		$(this.container).addClass("tabbed");
	 	};
	 	
	 };
	 
	 // Convert each of the main sections into tabs (tabbed content).
	 var tabs = new Tabs($("main"));
	 $("main > .contents li").each(function(){
	 	var i = $(this).prevAll().length;
	 	tabs.createTab($("main > section").eq(i), this);
	 
	 });
	 
	 var routesSubTabs = new Tabs($("section#routes")); 
	 var subsectionHeadings = [];
	 $("section#routes > section > h3").each(function(){
	    subsectionHeadings.push($(this).text());
	 });
	 $("section#routes > h2").after("<div class=\"contents\"><h3 class=\"heading\">Contents</h3><nav><ul></ul></nav></div>");
	 for (var i = 0; i < subsectionHeadings.length; i++) {
	     $("section#routes > .contents ul").append("<li>" + subsectionHeadings[i] + "</li>");
	 };
	 $("section#routes > .contents li").each(function(){
		var i = $(this).prevAll().length;
	 	routesSubTabs.createTab($("section#routes > section").eq(i), this);
	 });
	
	 
	 tabs.init();
	 routesSubTabs.init();
	
	generateVisualisations($);
	
});