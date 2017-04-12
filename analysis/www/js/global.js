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
	$("main > section").filter(":first").addClass("focus");
	$("main > .contents li:first-child").addClass("focus");
	$("main > .contents a").each(function(){
		$(this).replaceWith(this.childNodes);	
	});
	$("main > .contents li").click(function(){
		$("main > .contents li, main > section").removeClass("focus");
		$(this).addClass("focus");
		var i = $(this).prevAll().length;
		$("main > section").eq(i).addClass("focus");
	});
	$("main").addClass("tabbed");
		
	generateVisualisations($);
	
});