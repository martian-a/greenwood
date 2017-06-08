var networkVisualisations = [];

var generateVisualisations = function generateVisualisations($) {
  
	/* 
	 * Make a deep copy of an existing colletion of nodes,
	 * and customise for use in tickets network visualisation
	 */  
	function prepTicketsNodeData(source) {
		
		// Make a deep copy of the source data
		var clone = source.slice(0);
	    clone.forEach(function(item){
	        item.mass = 10;
	        item.size = 30;
	    });
	    
		return clone;
	};

	
	/* 
	 * Make a deep copy of an existing collection of edges,
	 * and customise for use in tickets network visualisation
	 */  
	function prepTicketsEdgeData(source) {
		
		// Make a deep copy of the source data
		var clone = source.slice(0);
		
	    var prevEdge;
	    var simplifiedClone = jQuery.grep(clone, function(item, i){
	        if (i > 0) {
	            prevEdge = clone[i-1];
	            if (item.from == prevEdge.from && item.to == prevEdge.to && item.length == prevEdge.length) {
	            	return false;
	            };
	        };
	        return true;
	    });
	    clone = simplifiedClone;
	    clone.forEach(function(item){
	        item.hidden = 'true';
	    });
		
		return clone;
	};


	/* 
	 * Default settings for locations network visualisation 
	 */
	var routesOptions = {
		autoResize: true,
		width: '100%',
		height: '100%',
		layout: {
			improvedLayout: true
		},
	    nodes: {
	        shape: 'dot',
	        mass: 1,
	        font: {
	        	size: 100,
	        	face: 'RosarioBold'
	        }
	    },
	    edges: {
	        width: 24,
	        smooth: {
	        	type: 'dynamic',
	        	forceDirection: 'none'
	        }
	    },
	    physics: {
	        solver: 'barnesHut',
	        barnesHut: {
	            gravitationalConstant: -2000,
	            centralGravity: 0.1,
	            springLength: 95,
	            springConstant: 0.01,
	            damping: 0.09,
	            avoidOverlap: 1
	        },
	        maxVelocity: 50,
	        minVelocity: 0.1,
	        timestep: 0.5,
	        stabilization: {
	            onlyDynamicEdges: true,
	            fit: true
	        }
	    },
	    interaction: {
	    	zoomView: true
	    }
	};
	
 
	if (storedLayout == true) {
		routesOptions.physics.stabilization.enabled = false;
		routesOptions.physics.maxVelocity = 1;
		routesOptions.physics.minVelocity = 0;
	}
	
	
		
	/* 
	 * Default settings for tickets network visualisation 
	 */
	var ticketsOptions = routesOptions;
		
	
	/* 
	 * Create a vis.js network visualisation  
	 */	
	function networkVisualisation(containerId, nodesData, edgesData, optionsIn) {
		
		this.container;
		this.controls;
		this.canvas;
		this.data;
		this.options = optionsIn;
		this.network;
		this.stabilized = false;
		
		this.getData = function(){
			return this.data;
		};
		this.getNodes = function(){
			return this.data.nodes;
		};
		this.getEdges = function(){
			return this.data.edges;
		};
		this.getNetwork = function() {
			return this.network;
		};
		this.getCanvas = function() {
			return this.canvas;
		};
		this.getOptions = function(){
			return this.options;
		};
		this.getId = function(){
			return this.container.getAttribute("id");
		};
		this.isVisible = function(){
			if ($(this.container).is(":visible")) {
				return true;
			}
			return false;
		};
		this.isStabilized = function(){
			return this.stabilized;
		};
		
		this.bestFit = function() {		
			
			if (!this.isVisible()) {
				return;
			};
			
			var network = this.getNetwork();
			var canvas = this.getCanvas();
			var wasStabilized = this.isStabilized();
			
			network.moveTo({scale:1}); 
			network.stopSimulation();
			
			var bigBB = { top: Infinity, left: Infinity, right: -Infinity, bottom: -Infinity }
			this.data.nodes.getIds().forEach( function(i) {
				var bb = network.getBoundingBox(i);
				if (bb.top < bigBB.top) bigBB.top = bb.top;
				if (bb.left < bigBB.left) bigBB.left = bb.left;
				if (bb.right > bigBB.right) bigBB.right = bb.right;
				if (bb.bottom > bigBB.bottom) bigBB.bottom = bb.bottom;  
			});
			
			var canvasWidth = 0.9 * canvas.clientWidth;
			var canvasHeight = 0.9 * canvas.clientHeight; 
			
			var networkHeight = bigBB.bottom - bigBB.top;
			var networkWidth = bigBB.right - bigBB.left;
			
			/* 
			 * Reminder: 
			 * 	X = horizontal/width 
			 * 	Y = vertical/height
			 */
			var scaleX = canvasWidth/networkWidth;
			var scaleY = canvasHeight/networkHeight;	
			
			var scale = scaleX;
			if ((scale * networkHeight) > canvasHeight ) {
				scale = scaleY;	
			};
			
			network.moveTo({
				scale: scale,
				position: {
				  x: (bigBB.right + bigBB.left)/2,
				  y: (bigBB.bottom + bigBB.top)/2
				}
			});
			
			if (wasStabilized == false) {
				network.startSimulation();				
			};
	
		};
		
		networkVisualisation.updateAll = function() {
		
			for (var i = 0; i < networkVisualisations.length; i++) {
				networkVisualisations[i].bestFit();
			};
		};
		
		this.setStabilized = function(state){
			
			if (state == true) {
				this.stabilized = true;
			} else if (state == false) {
				this.stabilized = false;
			};
			

			var freezeLabel;
			if (this.isStabilized()) {
				freezeLabel = "Unfreeze";
			} else {
				freezeLabel = "Freeze";
			}
			
			if (($(this.controls).find("button.freeze")).length < 1) {
				$(this.controls).append("<button class=\"freeze\">" + freezeLabel + "</button>");
				var self = this;
				$(this.controls).find("button.freeze").on("click", function(){
					self.toggleFreeze();
				});
			} else {
				$(this.controls).find("button.freeze").text(freezeLabel);	
			}
			
		};
		
		this.toggleFreeze = function() {
			
			var network = this.getNetwork();
			if (this.isStabilized()) {
				network.startSimulation();
			} else {
				network.stopSimulation();
			}
			
		};
		
		if (!this.network) {
			
			var self = this;
			this.container = document.getElementById(containerId);
			var canvasId = this.getId() + "-canvas";
			$(this.container).append("<div class=\"canvas\" id=\"" + canvasId + "\" /><div class=\"controls\" />");
			this.canvas = document.getElementById(canvasId);
			this.controls = $(this.container).find(".controls");
			var nodes = new vis.DataSet(nodesData);
			var edges = new vis.DataSet(edgesData);
		    this.data = {
	       	 	nodes: nodes,
	        	edges: edges
	        };
			this.network = new vis.Network(this.canvas, this.data, this.options);
			networkVisualisations.push(this);
			if (!showHide.has(networkVisualisation.updateAll)) {
				showHide.add(networkVisualisation.updateAll);
			};
			 
			
			this.network.on("stabilized", function(){
				self.setStabilized(true);
				
			}); 
			this.network.on("startStabilizing", function(){				
				self.setStabilized(false);
			}); 
			
			this.bestFit();
		};
	
	};

  
  	/* 
	 * Generate routes network visualisation
	 */
	var routesNetwork = new networkVisualisation('vis1', routesNodeData, routesEdgeData, routesOptions);
	
	/* 
	 * Generate tickets network visualisation
	 */
	 
	// Clone routesNodesData, reset mass and size.
	var ticketsNodeData = prepTicketsNodeData(routesNodeData);
            
    // Clone routesEdgesData, delete double edges.
    var simplifiedRoutesEdgeData = prepTicketsEdgeData(routesEdgeData);
            
 	ticketsEdgeData = simplifiedRoutesEdgeData.concat(ticketsEdgeData);
            
    // Populate a vis network visualisation
	var ticketsNetwork = new networkVisualisation('vis2', ticketsNodeData, ticketsEdgeData, ticketsOptions);
	
	update($);
	
};