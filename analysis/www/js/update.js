function update($) {
	
	$("#network").append("<button id=\"save-network\">Update Saved Layout</button>");
	$("#ticket-distribution").append("<button id=\"save-tickets\">Update Saved Layout</button>");
	
	function getData(network) {
	
		var positions = network.getPositions();
		var json = JSON.stringify(positions);
		
		$.post(
			"/exist/apps/greenwood/utils/update/network.xq?game=" + gameId, 
			"json=" + json, 
			function(data, status){
				alert(status),
			'xml';
		});
	};
	
	$("#save-network").on("click", function(){
		getData(routesNetworkCollection.getNetwork());
	});
	$("#save-tickets").on("click", function(){
		getData(ticketsNetworkCollection.getNetwork());		
	});
	
};