<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="no" method="xml" media-type="text/xml" omit-xml-declaration="no" />
	
	<xsl:strip-space elements="*" />
	
	<xsl:param name="filename" select="tokenize(translate(document-uri(/), '\', '/'), '/')[last()]" as="xs:string" />
	<xsl:param name="route" select="'false'" as="xs:string" />
	<xsl:param name="debug" select="'false'" as="xs:string" />
    
    
    
    
    <xsl:template match="/game/map/network[nodes/node][edges/edge]">
    	<xsl:variable name="network" select="self::network" as="element()?" />

    	<game>
    		<xsl:copy-of select="/game/@id" />
    		<map>
	    		<shortest-paths>
	    			
	    			<!-- 
	    				Loop through all the nodes in the network.
	    				For each node:
	    				- calculate the shortest path from that node to each other node in the network
	    				- record the route taken for each shortest path (optional and there may be more than one possible route)
	    			-->
		    		<xsl:for-each select="$network/nodes/node">
		    			
		    			<!-- Record the node from which the shortest paths will originate (start) -->
						<xsl:variable name="initial" select="self::node" as="element()" />
						
						<!-- 
							Create a list of all the nodes in the network.
							For each node, record:
							- its @id
							- whether the shortest distance between this node and the initial node has yet been calculated (@visited)
							- this shortest @distance between this node and the initial node:
								- the distance for the initial node is set to 0 (distance between itself to itself).
								- the distance on other nodes is set to infinity (as it is currently unknown).
							
							(Reminder: this list is reset each time the initial node changes.)
						-->
						<xsl:variable name="all" as="element()*">
							<xsl:for-each select="$network/nodes/node">
								<xsl:copy>
									<xsl:copy-of select="@id" />
									<xsl:attribute name="distance">
										<xsl:choose>
											<xsl:when test="current()[@id = $initial/@id]">0</xsl:when>
											<xsl:otherwise>∞</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
									<xsl:attribute name="visited" select="false()" />
								</xsl:copy>
							</xsl:for-each>
						</xsl:variable>
		    			
		    			<!-- 
		    				Identify the shortest route(s) between the inial node and each other node in the network.
		    			-->
						<xsl:for-each select="$initial/following-sibling::node">
							<xsl:call-template name="distance-check">
								<xsl:with-param name="initial" select="$initial" as="element()" tunnel="yes" />
								<xsl:with-param name="current" select="$all[@id = $initial/@id]" as="element()" />
								<xsl:with-param name="target" select="current()" as="element()" />
								<xsl:with-param name="all" select="$all" as="element()*" />
								<xsl:with-param name="network" select="$network" as="element()" tunnel="yes" />
								<xsl:with-param name="record-route" select="xs:boolean($route)" as="xs:boolean" tunnel="yes" />
							</xsl:call-template>
						</xsl:for-each>
		    			
					</xsl:for-each>
	    			
	    			
	    		</shortest-paths>
    		</map>
    	</game>
    	
    </xsl:template>
	
	
	<xsl:template name="distance-check">
		
		<!-- The starting point for the shortest path that's currently being sought. -->
		<xsl:param name="initial" as="element()" tunnel="yes" />
		
		<!-- The node in the network for which the distance between itself and the initial node is currently being calculated. -->
		<xsl:param name="current" as="element()" />
		
		<!-- The end point for the shortest path that's currently being sought. -->
		<xsl:param name="target" as="element()" />
		
		<!-- The working list of all nodes and the shortest path between them and the initial node -->
		<xsl:param name="all" as="element()*" />
		
		<!-- A handy reference to the network map. -->
		<xsl:param name="network" as="element()" tunnel="yes" />
		
		<!-- Whether to record the route(s) that can be taken for the shortest path.	-->
		<xsl:param name="record-route" as="xs:boolean" tunnel="yes" />
		
		<!-- 
			A list of all the nodes for which the shortest distance between each and the initial node has yet to be calculated.
			(This is a subset of the nodes in $all).	
		-->
		<xsl:variable name="unvisited" select="$all[@visited = false()]" as="element()*" />
		
		<!-- 
			A list of all the nodes that are immediate neighbours of the node currently being checked,
			that haven't already been checked.
			(This is a subset of the nodes in $unvisited).
		-->
		<xsl:variable name="unvisited-neighbours-of-current" select="$unvisited[@id != $current/@id][@id = $network/edges/edge[node/@ref = $current/@id]/node/@ref]" as="element()*" />
		
		<!-- $unvisited-neighbours-of-current updated to record the distance between each and the $initial node (and, optionally, the route(s) taken). --> 
		<xsl:variable name="tentative" as="element()*">
			
			<!-- 
				Loop through all the $unvisited-neighbours-of-current and for each:
				- calculate the distance between it and the initial node
				- record the route(s) between it and the initial node (optional)
			-->
			<xsl:for-each select="$network/edges/edge[node/@ref = $current/@id]/node[@ref = $unvisited-neighbours-of-current/@id]">
				
				<xsl:copy>
					
					<!-- The @id of this unvisited neighbour -->
					<xsl:attribute name="id" select="@ref" />
					
					<!-- The distance between the $initial node and this unvisited neighbour --> 
					<xsl:attribute name="distance" select="if ($current/@distance = '∞') then parent::edge/@length else sum($current/@distance + parent::edge/@length)" />
					
					<!-- Whether this neighbour has yet been the $current node
						(always false as otherwise it wouldn't be unvisited) -->
					<xsl:attribute name="visited" select="false()" />
					
					<!-- The route(s) between the $initial node and this unvisited neighbour -->
					<xsl:if test="$record-route">
						
						<xsl:variable name="via" select="$current/via" as="element()*" />
						
						<xsl:choose>
							
							<!-- 
								No other nodes need to be travelled through for this route between
								the $initial node and this unvisited neighbour
							-->
							<xsl:when test="$current/@id = $initial/@id">
								<via direct="true" />
							</xsl:when>
							
							<!-- 
								The route between the $initial node and this unvisited neighbour 
								involves travelling through other nodes.
							-->
							<xsl:otherwise>
								<xsl:choose>
									
									<!-- Requires travel through only the $current node -->
									<xsl:when test="not($via)">
										<via>
											<node ref="{$current/@id}" />
										</via>
									</xsl:when>
									
									<!-- Requires travel through more than one other node. -->
									<xsl:otherwise>
										<xsl:for-each select="$via">
											<via>
												<xsl:copy-of select="node" />
												<node ref="{$current/@id}" />
											</via>
										</xsl:for-each>
									</xsl:otherwise>
									
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
	
	
		
		<xsl:variable name="updated-distances" as="element()*">
		
			<xsl:for-each select="$all">
				
				<xsl:variable name="current-distance" select="if (@distance = '∞') then () else @distance" as="xs:integer?" />
				
				<xsl:choose>
					
					<!-- 
						Mark the $current node as having been visited.
						(The distances from $initial to all the neighbours of $current have now all been calculated.)
					-->
					<xsl:when test="@id = $current/@id">
						<xsl:copy>
							<xsl:attribute name="visited" select="true()" />
							<xsl:copy-of select="@id, @distance, via" />
						</xsl:copy>
					</xsl:when>
					
					<!--
						Check the distance from $initial to the immediate neighbours of $current.
						If the new tentative path is shorter than the current known shortest path,
						replace the saved one with the new value.
					-->
					<xsl:when test="self::*[@id = $tentative/@id][
							(@distance = '∞') or 
							(@distance != '∞' and @id = $tentative[xs:integer(@distance) &lt; $current-distance]/@id)
						]">
						<!-- 
							It's possible for there to be two (or more) edges between a pair of nodes, 
							for example, between Weymouth and Fortuneswell on the West Dorset map:
							- ferry (6)
							- normal (4)
						-->
						<xsl:for-each-group select="$tentative[@id = current()/@id]" group-by="@distance">
							<xsl:sort select="@distance" data-type="number" order="ascending" />
							<xsl:sort select="@id" data-type="text" order="ascending" />
							<xsl:if test="position() = 1">
								<xsl:copy-of select="current-group()[1]" />
							</xsl:if>
						</xsl:for-each-group>
					</xsl:when>
					
					<!--
						Check the distance from $initial to the immediate neighbours of $current.
						If the new tentative path is equal to the current known shortest path,
						append the tentative via to the updated data.
					-->
					<xsl:when test="self::*[@id = $tentative/@id][@distance != '∞'][@id = $tentative[xs:integer(@distance) = $current-distance]/@id]">
						<!-- 
							It's possible for there to be two (or more) edges between a pair of nodes, 
							for example, between Weymouth and Fortuneswell on the West Dorset map:
							- ferry (6)
							- normal (4)
						-->
						<xsl:copy>
							<xsl:copy-of select="@*, node()[not(self::via)]" />
							<xsl:for-each-group select="via | $tentative[@id = current()/@id][xs:integer(@distance) = $current-distance]/via" group-by="concat(@direct, ';', string-join(node/@ref, ';'))">
								<xsl:copy-of select="current-group()[1]" />
							</xsl:for-each-group>
						</xsl:copy>
					</xsl:when>
					
					<!-- 
						This node is not an immediate neighbour of $current (not in $tentative)
						or the tentative distance is greater than the current known shortest path.
						Retain the current values.
					-->
					<xsl:otherwise>
						<xsl:copy-of select="self::*" />
					</xsl:otherwise>
					
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
		
		<!-- 
			Build a list of all the as-yet unvisited nodes.
		-->
		<xsl:variable name="queue" as="element()*">
			<xsl:for-each select="$updated-distances[@visited = false()][@distance != '∞']">
				<xsl:sort select="@distance" data-type="number" order="ascending" />
				<xsl:sort select="@id" data-type="text" order="ascending" />
				<xsl:copy-of select="self::*" />
			</xsl:for-each>
			<xsl:for-each select="$updated-distances[@visited = false()][@distance = '∞']">
				<xsl:sort select="@id" data-type="text" order="ascending" />
				<xsl:copy-of select="self::*" />
			</xsl:for-each>
		</xsl:variable>
		
		
		<xsl:choose>
			
			<!-- All nodes have been visited -->
			<xsl:when test="count($queue) &lt; 1">
				<path distance="{$updated-distances[@id = $target/@id]/@distance}">
					<location ref="{$initial/@id}" />
					<location ref="{$target/@id}" />
					<xsl:apply-templates select="$updated-distances[@id = $target/@id]/via" />
				</path>
			</xsl:when>
			
			<!-- 
				One or more nodes remains unvisited.
				Visit the first node in the current $queue.
			-->
			<xsl:otherwise>
				<xsl:call-template name="distance-check">
					<xsl:with-param name="current" select="$queue[1]" as="element()" />					
					<xsl:with-param name="target" select="$target" as="element()" />
					<xsl:with-param name="all" select="$updated-distances" as="element()*" />
				</xsl:call-template>
			</xsl:otherwise>
			
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="via">
		<xsl:copy>
			<xsl:apply-templates select="@*, node" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="via/@direct">
		<xsl:copy-of select="." />
	</xsl:template>
	
	<xsl:template match="via/node">
		<location>
			<xsl:copy-of select="@ref" />
		</location>
	</xsl:template>


</xsl:stylesheet>