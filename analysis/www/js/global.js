jQuery(document).ready(function() {
	jQuery("main > section").filter(":first").addClass("focus");
	jQuery("main > .contents li:first-child").addClass("focus");
	jQuery("main > .contents a").each(function(){
		jQuery(this).replaceWith(this.childNodes);	
	});
	jQuery("main > .contents li").click(function(){
		jQuery("main > .contents li, main > section").removeClass("focus");
		jQuery(this).addClass("focus");
		var i = jQuery(this).prevAll().length;
		jQuery("main > section").eq(i).addClass("focus");
	});
	jQuery("main").addClass("tabbed");
});