<xsl:stylesheet 
	xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	version="2.0"
	exclude-result-prefixes="#all">
	
	
    <xsl:template match="/">
        <html>
            <head>
                <xsl:apply-templates mode="html.header"/>
            </head>
            <body>
                <xsl:apply-templates mode="html.body"/>
            </body>
        </html>
    </xsl:template>
    
    
    <xsl:template match="games" mode="html.header">
        <title>Games</title>
    </xsl:template>
    
    
    <xsl:template match="game" mode="html.header">
        <title>
            <xsl:value-of select="title"/>
        </title>
        <script type="text/javascript" src="../../js/vis.js"/>
        <link type="text/css" href="../../js/vis.css" rel="stylesheet"/>
        <style type="text/css">
            div.locations ul {
                -webkit-column-count: 3; /* Chrome, Safari, Opera */
                -moz-column-count: 3; /* Firefox */
                column-count: 3;
                -webkit-column-gap: 5em; /* Chrome, Safari, Opera */
                -moz-column-gap: 5em; /* Firefox */
                column-gap: 5em;
            }
            
            table.cross-reference {
                border-collapse: collapse;
            }
            table.cross-reference th,
            table.cross-reference td {
                border: 1px solid black;
                padding: .25em;
            }
            table.cross-reference th {
                text-align: left;
                white-space: wrap;
            }
            table.cross-reference td {
                text-align: center;
            }
            table.cross-reference td.empty {
                background-color: #c0c0c0;
            }
            table.cross-reference th.destination {
                height: 12em;
                white-space: nowrap;
                width: 2em;
            }
            table.cross-reference th.destination span {
                display: block;
                position: relative;
                width: 1.5em;
                line-height: 2em;
                margin: 0;
                transform: rotate(-90deg);
                transform-origin: 3.25em 3.25em 0;
            }
            table.cross-reference th.total {
                whitespace: wrap;
                width: 3em;
                vertical-align: bottom;
            }
            table.cross-reference td.destination {
                text-align: left;
                font-weight: bold;
            }
            
            span.ticket {
                display: inline-block;
                font-size: 1.25em;
                margin: 0;
                vertical-align: middle;
                padding-left: .25em;
                transform: rotate(-10deg);
            }
            
            #mynetwork {
                width: 1200px;
                height: 800px;
                border: 1px solid lightgray;
                background-color: #f5f5f5;
            }
        </style>
    </xsl:template>
    
    
    <xsl:template match="games" mode="html.body">
        <p>
            <a href="../xml/game.xml">XML</a>
        </p>
        <h1>Games</h1>
        <ul>
            <xsl:for-each select="//game">
                <li>
                    <a href="game.html?id={@id}">
                        <xsl:apply-templates select="." mode="game.name"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
    
    <xsl:template match="game" mode="html.body">
        <p>
            <a href="game.html">Games</a> | <a href="../xml/game.xml?id={@id}">XML</a>
        </p>
        <h1>
            <xsl:value-of select="title"/>
        </h1>
        <xsl:apply-templates select="map/routes">
            <xsl:with-param name="colour" select="map/colours/colour" as="element()*" tunnel="yes"/>
        <xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="map/locations">
            <xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="map/shortest-paths">
            <xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
    <xsl:apply-templates select="tickets">
            <xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <xsl:template match="locations">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <div class="locations">
            <h2>Locations</h2>
            <p>Total: <xsl:value-of select="count(descendant::location)"/>
            </p>
            <ul>
                <xsl:for-each select="descendant::location">
                	<xsl:sort select="if (name) then name else ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending" />
                    <li>
                        <a href="location.html?id={$game-id}-{@id}">
                            <xsl:apply-templates select="." mode="location.name"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    
    
    <xsl:template match="routes">
        <xsl:param name="colour" as="element()*" tunnel="yes"/>
        <xsl:variable name="routes" select="." as="element()"/>
        <h2>Routes</h2>
        <h3>Network</h3>
        <div id="mynetwork"/>
        <script type="text/javascript">
            <!-- create an array with nodes -->
            <xsl:text>var nodes = new vis.DataSet([</xsl:text>
            <xsl:for-each select="ancestor::map[1]/locations/descendant::location">
                <xsl:variable name="total-tickets" select="count(ancestor::game[1]/tickets/ticket[location/@ref = current()/@id or country/@ref = current()/ancestor::country[1]/@id])" as="xs:integer" />
                <xsl:text>{
                    id: '</xsl:text>
                        <xsl:value-of select="@id"/>
                        <xsl:text>', 
                    label: '</xsl:text>
                        <xsl:apply-templates select="." mode="location.name">
                    <xsl:with-param name="for-js" select="true()" as="xs:boolean" tunnel="yes"/>
                </xsl:apply-templates>
                        <xsl:text>',
                    size: </xsl:text>
                        <xsl:value-of select="sum(10 * sum(1 + $total-tickets))" />
                        <xsl:text>,
                    mass: </xsl:text>
                        <xsl:value-of select="sum(1 + $total-tickets)" />
                        <xsl:text>
                }</xsl:text>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>]);</xsl:text>
            <!-- create an array with edges -->
            <xsl:text>var edges = new vis.DataSet([</xsl:text>
            <xsl:for-each select="route/(@colour | colour)">
                <xsl:variable name="route" select="ancestor::route[1]" />
                <xsl:variable name="colour" select="if (self::colour) then @ref else ."/>
                <xsl:text>{
                    from: '</xsl:text>
                        <xsl:value-of select="$route/location[1]/@ref"/>
                        <xsl:text>', 
                    to: '</xsl:text>
                        <xsl:value-of select="$route/location[2]/@ref"/>
                        <xsl:text>',
                    color: '</xsl:text>
                        <xsl:value-of select="gw:getColourHex($colour)"/>
                        <xsl:text>',
                    length: </xsl:text>
                        <xsl:value-of select="sum(150 * number($route/@length))" />
                        <xsl:text>
                }</xsl:text>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>]);</xsl:text>
            <!-- create a network -->
            <xsl:text>var container = document.getElementById('mynetwork');</xsl:text>
            <!-- provide the data in the vis format -->
            <xsl:text>
            var data = {
                nodes: nodes,
                edges: edges
            };
            </xsl:text>
            <!-- set options -->
            <xsl:text>
            var options = {
                nodes: {
                    shape: 'dot',
                    mass: 1
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
            </xsl:text>
            <!-- initialise the network -->
            <xsl:text>
            var network = new vis.Network(container, data, options);
            </xsl:text>
        </script>
        <h3>Options</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route/(@colour | colour/@ref))"/>
                </td>
            </tr>
            <tr>
            	<td>Value</td>
            	<xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="sum(
			21 * count($routes/route[@length = '8']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 
			18 * count($routes/route[@length = '7']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) +
			15 * count($routes/route[@length = '6']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 
			10 * count($routes/route[@length = '5']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) +
			7 * count($routes/route[@length = '4']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 
			4 * count($routes/route[@length = '3']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 
			2 * count($routes/route[@length = '2']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 
			count($routes/route[@length = '1']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))
		    )"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="sum(
			21 * count($routes/route[@length = '8']) + 
			18 * count($routes/route[@length = '7']) +
			15 * count($routes/route[@length = '6']) + 
			10 * count($routes/route[@length = '5']) +
			7 * count($routes/route[@length = '4']) + 
			4 * count($routes/route[@length = '3']) + 
			2 * count($routes/route[@length = '2']) + 
			count($routes/route[@length = '1'])
		)"/>
                </td>
            </tr>
        </table>
        <h3>Double Routes</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[count(colour) &gt; 1]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[count(colour) &gt; 1]/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[count(colour) &gt; 1]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[count(colour) &gt; 1]/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
        <h3>Tunnels</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[@tunnel = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[@tunnel = 'true']/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[@tunnel = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[@tunnel = 'true']/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
        
        <h3>Microlights</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[@microlight = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[@microlight = 'true']/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[@microlight = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[@microlight = 'true']/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
        <h3>Ferries</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[@ferry/number(.) > 0]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[@ferry/number(.) > 0]/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[@ferry/number(.) > 0]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[@ferry/number(.) > 0]/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    
    
    
    <xsl:template match="shortest-paths">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <xsl:variable name="paths" select="path" as="element()*"/>
        <xsl:variable name="destinations" as="element()*">
            <xsl:for-each-group select="descendant::path/location" group-by="@ref">
                <xsl:copy-of select="ancestor::game[1]/map/locations/descendant::*[name() = ('location', 'country')][@id = current-grouping-key()]"/>
            </xsl:for-each-group>
        </xsl:variable>
        <div class="shortest-paths">
            <h2>Shortest Paths</h2>
            <table class="cross-reference">
                <tr>
                    <th> </th>
                    <xsl:for-each select="$destinations">
                        <xsl:sort select="name" data-type="text" order="ascending"/>
                        <th class="destination">
                            <span>
                                <xsl:apply-templates select="." mode="location.name"/>
                            </span>
                        </th>
                    </xsl:for-each>
                </tr>
                <xsl:for-each select="$destinations">
                    <xsl:sort select="name" data-type="text" order="ascending"/>
                    <xsl:variable name="from" select="." as="element()"/>
                    <xsl:variable name="paths-from" select="$paths[*/@ref = $from/@id]" as="element()*"/>
                    <tr>
                        <td class="destination">
                            <xsl:apply-templates select="$from" mode="location.name"/>
                        </td>
                        <xsl:for-each select="$destinations">
                            <xsl:sort select="name" data-type="text" order="ascending"/>
                            <xsl:variable name="to" select="." as="element()"/>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="$from/@id = $to/@id">
                                        <xsl:attribute name="class">self</xsl:attribute>
                                        <xsl:text>-</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="not($paths-from[*/@ref = $to/@id])">
                                        <xsl:attribute name="class">empty</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$paths-from[*/@ref = $to/@id]/@distance"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>
                    </tr>
                </xsl:for-each>
            </table>
            <h2>By Distance</h2>
            <ul>
                <xsl:for-each-group select="path" group-by="@distance">
                    <xsl:sort select="current-grouping-key()" data-type="number" order="ascending"/>
                    <li>
                        <h3>
                            <xsl:value-of select="current-grouping-key()"/> Carriage<xsl:if test="current-grouping-key() != 1">s</xsl:if> (<xsl:value-of select="count(current-group())"/> paths)</h3>
                        <ul>
                            <xsl:for-each select="current-group()">
                                <li>
                                    <xsl:apply-templates select="." mode="path.name"/>
                                    <xsl:for-each select="ancestor::game[1]/tickets/ticket[location/@ref = current()/location[1]/@ref][location/@ref = current()/location[2]/@ref]">
                                         <span class="ticket">🎫</span>
                                  	<span class="ticket-value">[<xsl:value-of select="@points"/>]</span>
                                    </xsl:for-each>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </li>
                </xsl:for-each-group>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="tickets">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <xsl:variable name="tickets" select="ticket" as="element()*" />
    	<xsl:variable name="destinations" as="element()*">
    		<xsl:for-each-group select="descendant::ticket/location" group-by="@ref">
    			<xsl:copy-of select="ancestor::game[1]/map/locations/descendant::location[@id = current-grouping-key()]" />
    		</xsl:for-each-group>
    		<xsl:for-each-group select="descendant::ticket/country" group-by="@ref">
    			<xsl:copy-of select="ancestor::game[1]/map/locations/descendant::country[@id = current-grouping-key()]" />
    		</xsl:for-each-group>
    	</xsl:variable>
    	
        <div class="tickets">
            <h2>Tickets</h2>
            <p>Total: <xsl:value-of select="count(descendant::ticket)"/></p>
            <table class="cross-reference">
            	<tr>
            		<th> </th>
            		<xsl:for-each select="$destinations">
            			<xsl:sort select="name" data-type="text" order="ascending" />
            			<th class="destination">
                            <span>
                                <xsl:apply-templates select="." mode="location.name"/>
                            </span>
                        </th>
            		</xsl:for-each>
            		<th class="total">Total Tickets</th>
            		<th class="total">Max Points</th>
            	</tr>
            	<xsl:for-each select="$destinations">
            		<xsl:sort select="name" data-type="text" order="ascending" />
            		<xsl:variable name="from" select="." as="element()" /> 
            		<xsl:variable name="tickets-from" select="$tickets[*/@ref = $from/@id]" as="element()*" />
            		<tr>
            			<td class="destination">
                            <xsl:apply-templates select="$from" mode="location.name"/>
                        </td>
            			<xsl:for-each select="$destinations">
	            			<xsl:sort select="name" data-type="text" order="ascending" />
            				<xsl:variable name="to" select="." as="element()" />
	            			<td>
	            				<xsl:choose>
	            					<xsl:when test="$from/@id = $to/@id">
    	            					<xsl:attribute name="class">self</xsl:attribute>
    	            					<xsl:text>-</xsl:text>
	            					</xsl:when>
	                                <xsl:when test="not($tickets-from[*/@ref = $to/@id])">
	                                    <xsl:attribute name="class">empty</xsl:attribute>
	                                </xsl:when>
	            					<xsl:otherwise>
	            						<xsl:value-of select="
	            						    sum($tickets-from[*/@ref = $to/@id]/@points) + 
	            						    sum($tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]/*[@ref = $to/@id]/@points) + 
	            						    sum($tickets-from[not(@points)][*[not(@points)]/@ref = $to/@id]/*[@ref = $from/@id]/@points)
	            						" />
	            					</xsl:otherwise>
	            				</xsl:choose>
	            			</td>
            		    </xsl:for-each>
            		    <td><xsl:value-of select="count($tickets-from)" /></td>
            		    <td>
            		        <xsl:variable name="max-points" as="element()*">
            		            <!-- city-to-city tickets -->
            		            <xsl:for-each select="$tickets-from[@points]">
            		                <points><xsl:value-of select="@points" /></points>
            		            </xsl:for-each>
            		            <!-- dependency on this location -->
            		            <xsl:for-each select="$tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]">
            		                <!-- Find the destination with the highest points -->
            		                <xsl:for-each select="*[@points]">
            		                    <xsl:sort select="@points" data-type="number" order="descending" />
            		                    <xsl:if test="position() = 1">
            		                        <points><xsl:value-of select="@points" /></points>
            		                    </xsl:if>
            		                </xsl:for-each>
            		            </xsl:for-each>
            		            <!--dpendency on another location -->
            		            <xsl:for-each select="$tickets-from[not(@points)]/*[@ref = $from/@id][@points]">
            		                <points><xsl:value-of select="@points" /></points>
            		            </xsl:for-each>
            		        </xsl:variable>
            		        <xsl:value-of select="sum($max-points)" />
            		    </td>
            		</tr>
            	</xsl:for-each>
            </table>
            <h2>By Total Tickets</h2>
            <table>
            	<tr>
            		<th>Location</th>
            		<th>Total Tickets</th>
            		<th>Max Points</th>
            		<th>Points per Ticket</th>
            	</tr>
            	<xsl:for-each-group select="$tickets" group-by="*[self::location or self::country]/@ref">
            		<xsl:sort select="count(current-group())" data-type="number" order="descending" />
            		<xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending" />
            		<xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending" />
            		<xsl:variable name="total-tickets" select="count(current-group())" />
            		<xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" />
            		<tr>
            			<td>
							<xsl:choose>
								<xsl:when test="$destinations[@id = current-grouping-key()]">
									<a href="location.html?id={$game-id}-{current-grouping-key()}"><xsl:apply-templates select="$destinations[@id = current-grouping-key()]" mode="location.name" /></a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="current-grouping-key()" />
								</xsl:otherwise>
							</xsl:choose>
            			</td>
            			<td><xsl:value-of select="$total-tickets" /></td>
            			<td><xsl:value-of select="$max-points" /></td>
            			<td><xsl:value-of select="format-number($max-points div $total-tickets, '0.#')" /></td>
            		</tr>
            	</xsl:for-each-group>
            	<xsl:for-each select="ancestor::game[1]/map/locations/descendant::location[not(@id = $destinations/@id)][not(ancestor::country[1]/@id = $destinations/@id)]">
            		<tr>
            			<td>
							<a href="location.html?id={$game-id}-{@id}"><xsl:apply-templates select="." mode="location.name" /></a>
            			</td>
            			<td>0</td>
            			<td>0</td>
            			<td>0</td>
            		</tr>
            	</xsl:for-each>
            </table>
            <h2>By Max Points</h2>
            <table>
            	<tr>
            		<th>Location</th>
            		<th>Max Points</th>
            		<th>Points per Ticket</th>
            		<th>Total Tickets</th>
            	</tr>
            	<xsl:for-each-group select="$tickets" group-by="*[self::location or self::country]/@ref">
            		<xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending" />
            		<xsl:sort select="count(current-group())" data-type="number" order="ascending" />
            		<xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending" />
            		<xsl:variable name="total-tickets" select="count(current-group())" />
            		<xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" />
            		<tr>
            			<td>
							<xsl:choose>
								<xsl:when test="$destinations[@id = current-grouping-key()]">
									<a href="location.html?id={$game-id}-{current-grouping-key()}"><xsl:apply-templates select="$destinations[@id = current-grouping-key()]" mode="location.name" /></a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="current-grouping-key()" />
								</xsl:otherwise>
							</xsl:choose>
            			</td>
            			<td><xsl:value-of select="$max-points" /></td>
            			<td><xsl:value-of select="format-number($max-points div $total-tickets, '0.#')" /></td>
            			<td><xsl:value-of select="$total-tickets" /></td>
            		</tr>
            	</xsl:for-each-group>
            </table>
            <h2>By Points per Ticket</h2>
            <table>
            	<tr>
            		<th>Location</th>
            		<th>Points per Ticket</th>
            		<th>Total Tickets</th>
            		<th>Max Points</th>
            	</tr>
            	<xsl:for-each-group select="$tickets" group-by="*[self::location or self::country]/@ref">
            		<xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key())) div count(current-group())" data-type="number" order="descending" />
            		<xsl:sort select="count(current-group())" data-type="number" order="descending" />
            		<xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending" />
            		<xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending" />
            		<xsl:variable name="total-tickets" select="count(current-group())" />
            		<xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" />
            		<tr>
            			<td>
							<xsl:choose>
								<xsl:when test="$destinations[@id = current-grouping-key()]">
									<a href="location.html?id={$game-id}{current-grouping-key()}"><xsl:apply-templates select="$destinations[@id = current-grouping-key()]" mode="location.name" /></a>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="current-grouping-key()" />
								</xsl:otherwise>
							</xsl:choose>
            			</td>
            			<td><xsl:value-of select="format-number($max-points div $total-tickets, '0.#')" /></td>
            			<td><xsl:value-of select="$total-tickets" /></td>
            			<td><xsl:value-of select="$max-points" /></td>
            		</tr>
            	</xsl:for-each-group>
            </table>
            <h2>By Type</h2>
            <ul>
            	<li>
            		<h3>Settlement-to-settlement</h3>
            		<xsl:choose>
            			<xsl:when test="descendant::ticket[not(country)]">
	            			<ul>
				         		<xsl:for-each select="descendant::ticket[not(country)]">
				         		    <xsl:sort select="@points" data-type="number" order="ascending" />
				                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
				                </xsl:for-each>   			
		            		</ul>
            			</xsl:when>
            			<xsl:otherwise>
            				<p class="none">[none]</p>
            			</xsl:otherwise>
            		</xsl:choose>
            	</li>
            	<li>
            		<h3>Settlement-to-region</h3>
            		<xsl:choose>
            			<xsl:when test="descendant::ticket[location][country]">
	            			<ul>
				         		<xsl:for-each select="descendant::ticket[location][country]">
				                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
				                </xsl:for-each>   			
		            		</ul>
            			</xsl:when>
            			<xsl:otherwise>
            				<p class="none">[none]</p>
            			</xsl:otherwise>
            		</xsl:choose>
            	</li>
            	<li>
            		<h3>Region-to-region</h3>
            		<xsl:choose>
            			<xsl:when test="descendant::ticket[not(location)]">
	            			<ul>
				         		<xsl:for-each select="descendant::ticket[not(location)]">
				                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
				                </xsl:for-each>   			
		            		</ul>
            			</xsl:when>
            			<xsl:otherwise>
            				<p class="none">[none]</p>
            			</xsl:otherwise>
            		</xsl:choose>
            	</li>
            </ul>
        </div>
    </xsl:template>
    
    
    <xsl:template match="game" mode="game.name">
        <xsl:value-of select="title"/>
    </xsl:template>
    
    
    <xsl:template match="location[@ref] | country[@ref]" mode="location.name">
        <xsl:apply-templates select="ancestor::game[1]/map/locations/descendant::*[name() = current()/name()][@id = current()/@ref]" mode="#current" />
    </xsl:template>
    
    
    <xsl:template match="location[@id][name]" mode="location.name">
        <xsl:apply-templates select="name" mode="#current"/>
    </xsl:template>
    
    
    <xsl:template match="location[@id][not(name)]" mode="location.name">
        <xsl:value-of select="concat(ancestor::country[1]/name, ' (', @id, ')')"/>
    </xsl:template>
    
    
    <xsl:template match="country[@id]" mode="location.name">
        <xsl:apply-templates select="name" mode="#current"/>
    </xsl:template>
    
    
    <xsl:template match="name" mode="location.name">
        <xsl:param name="for-js" select="false()" tunnel="yes" as="xs:boolean"/>
	   
	   <!-- create an $apos variable to make it easier to refer to -->
        <xsl:variable name="apos" select="codepoints-to-string(39)"/>
        <xsl:choose>
	      <!-- if the string contains an apostrophe... -->
            <xsl:when test="$for-js = true() and contains(., $apos)">
                <xsl:value-of select="replace(., $apos, '\\''')"/>
            </xsl:when>
	      <!-- otherwise... -->
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="ticket[count(*) = 2]" mode="ticket.name">
    	<xsl:apply-templates select="*[1]" mode="location.name"/>
    	<xsl:text> to </xsl:text>
    	<xsl:apply-templates select="*[2]" mode="location.name" />
    	<xsl:value-of select="concat(' [', @points ,']')" />
    </xsl:template>
    
    
    <xsl:template match="ticket[count(*) > 2]" mode="ticket.name">
    	<xsl:apply-templates select="*[not(@points)]" mode="location.name" />
    	<xsl:text> to </xsl:text>
    	<xsl:for-each select="*[@points]">
    	    <xsl:sort select="@points" data-type="number" order="ascending" />
    		<xsl:apply-templates select="." mode="location.name" />
    		<xsl:value-of select="concat(' [', @points ,']')" />
    		<xsl:if test="position() != last()">
    			<xsl:text> or </xsl:text>
    		</xsl:if>
    	</xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="path" mode="path.name">
        <xsl:apply-templates select="*[1]" mode="location.name"/>
        <xsl:text> to </xsl:text>
        <xsl:apply-templates select="*[2]" mode="location.name"/>
    </xsl:template>
    <xsl:function name="gw:getColourHex" as="xs:string">
        <xsl:param name="colour-id" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$colour-id = 'RED'">#FF0000</xsl:when>
            <xsl:when test="$colour-id = 'ORA'">#FF8C00</xsl:when>
            <xsl:when test="$colour-id = 'YEL'">#FFD700</xsl:when>
            <xsl:when test="$colour-id = 'GRN'">#32CD32</xsl:when>
            <xsl:when test="$colour-id = 'BLU'">#4169E1</xsl:when>
            <xsl:when test="$colour-id = 'VIO'">#9370DB</xsl:when>
            <xsl:when test="$colour-id = 'BLA'">#000000</xsl:when>
            <xsl:when test="$colour-id = 'WHI'">#FFFFFF</xsl:when>
            <xsl:when test="$colour-id = 'GRY'">#C0C0C0</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$colour-id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="gw:getMaxPoints" as="xs:integer">
		<xsl:param name="ticket" as="element()" />
		<xsl:param name="location-id" as="xs:string?" />    
		
		<xsl:choose>
			<!-- Location is a settlement -->
			<xsl:when test="$ticket/location[@ref = $location-id]">
				<xsl:choose>
					<!-- settlement to settlement -->
					<xsl:when test="$ticket/@points">
						<xsl:value-of select="$ticket/@points" />
					</xsl:when>
					<!-- settlement to region (location is starting point) -->
					<xsl:when test="$ticket/location[@ref = $location-id][not(@points)]">
						<!-- Find the destination with the highest points -->
   		                <xsl:for-each select="$ticket/*[@points]">
   		                    <xsl:sort select="@points" data-type="number" order="descending" />
   		                    <xsl:if test="position() = 1">
   		                        <xsl:value-of select="@points" />
   		                    </xsl:if>
   		                </xsl:for-each>
					</xsl:when>
					<!-- settlement to region (location is destination)  -->
					<xsl:otherwise>
						<xsl:value-of select="$ticket/location[@ref = $location-id]/@points" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- Location is a region -->
			<xsl:when test="$ticket/country[@ref = $location-id]">
				<xsl:variable name="country-id" select="$location-id" />
				<xsl:choose>
					<!-- region to region (location is starting point) -->
					<xsl:when test="$ticket/country[@ref = $country-id][not(@points)]">
						<!-- Find the destination with the highest points -->
   		                <xsl:for-each select="$ticket/*[@points]">
   		                    <xsl:sort select="@points" data-type="number" order="descending" />
   		                    <xsl:if test="position() = 1">
   		                        <xsl:value-of select="@points" />
   		                    </xsl:if>
   		                </xsl:for-each>
					</xsl:when>
					<!-- region to region (location is destination) --> 
					<xsl:otherwise>
						<xsl:value-of select="$ticket/country[@ref = $country-id]/@points" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
    </xsl:function>


</xsl:stylesheet>