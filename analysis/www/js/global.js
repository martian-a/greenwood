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
	 function tab(containerElement, labelElement, keyIn, parent) {
	 	
	 	this.key = keyIn;
	 	this.container = containerElement;
	 	this.label = labelElement;
	 	this.tabs = parent;
	 	
	 	this.show = function(){
	 		$(this.container, this.label).addClass("focus");
	 	};
	 	this.hide = function(){
	 		$(this.container, this.label).removeClass("focus");
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
	 
	 function tabs(containerElement) {
	 	
	 	this.collection = new Array();
	 	this.container = containerElement;
	 	
	 	this.length = this.collection.length;	
	 	
	 	this.createTab = function(containerElement, labelElement){
	 		this.collection.push(new tab(containerElement, labelElement, this.collection.length + 1, this));
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
	 
	 var tabs = new tabs($("main"));
	 $("main > .contents li").each(function(){
	 	var i = $(this).prevAll().length;
	 	tabs.createTab($("main > section").eq(i), this);
	 
	 });
	 tabs.init();
	
	generateVisualisations($);
	
});