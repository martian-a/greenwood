function prepTicketsNodeData(source) {
	
	// Make a deep copy of the source data
	var clone = source.slice(0);
    clone.forEach(function(item){
        item.mass = 10;
        item.size = 30;
    });
    
	return clone;
};

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

var ticketsOptions = {
	width: '100%',
	height: '100%',
    nodes: {
        shape: 'dot',
        mass: 1,
        font: {
        	size: 50
        }
    },
    edges: {
        width: 12
    },
    physics: {
        barnesHut: {
            gravitationalConstant: -2000,
            centralGravity: 0.3,
            springLength: 95,
            springConstant: 0.04,
            damping: 0.25,
            avoidOverlap: 1
        },
        maxVelocity: 50,
        minVelocity: 0.5,
        solver: 'barnesHut',
        timestep: 0.5,
        stabilization: {
            enabled: true
        }
    }
};

var routesOptions = {
	width: '100%',
	height: '100%',
    nodes: {
        shape: 'dot',
        mass: 1,
        font: {
        	size: 50
        }
    },
    edges: {
        width: 12
    },
    physics: {
        barnesHut: {
            gravitationalConstant: -2000,
            centralGravity: 0.3,
            springLength: 95,
            springConstant: 0.04,
            damping: 0.09,
            avoidOverlap: 1
        },
        maxVelocity: 50,
        minVelocity: 0.1,
        solver: 'barnesHut',
        timestep: 0.5,
        stabilization: {
            enabled: true
        }
    }
};

function createNetwork(containerId, nodesData, edgesData, options) {

	var container = document.getElementById(containerId);

    var nodes = new vis.DataSet(nodesData);
	var edges = new vis.DataSet(edgesData);
    var data = {
        nodes: nodes,
        edges: edges
    };

	return new vis.Network(container, data, options)
};