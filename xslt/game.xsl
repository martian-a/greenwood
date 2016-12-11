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
        </xsl:apply-templates>
        <xsl:apply-templates select="tickets"/>
        <xsl:apply-templates select="map/locations"/>
    </xsl:template>
    <xsl:template match="locations">
        <div class="locations">
            <h2>Locations</h2>
            <p>Total: <xsl:value-of select="count(descendant::location)"/>
            </p>
            <ul>
                <xsl:for-each select="descendant::location">
                    <li>
                        <a href="location.html?id={@id}">
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
                <xsl:text>{
                    id: '</xsl:text>
                        <xsl:value-of select="@id"/>
                        <xsl:text>', 
                    label: '</xsl:text>
                        <xsl:apply-templates select="." mode="location.name"/>
                        <xsl:text>'
                }</xsl:text>
                <xsl:if test="position() != last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>]);</xsl:text>
            <!-- create an array with edges -->
            <xsl:text>var edges = new vis.DataSet([</xsl:text>
            <xsl:for-each select="route">
                <xsl:variable name="colour" select="if (@colour) then @colour else colour[1]/@ref"/>
                <xsl:text>{
                    from: '</xsl:text>
                        <xsl:value-of select="location[1]/@ref"/>
                        <xsl:text>', 
                    to: '</xsl:text>
                        <xsl:value-of select="location[2]/@ref"/>
                        <xsl:text>',
                    color: '</xsl:text>
                        <xsl:value-of select="gw:getColourHex($colour)"/>
                        <xsl:text>',
                    length: </xsl:text>
                        <xsl:value-of select="sum(100* number(@length))" />
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
                    width: 8
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
                    timestep: 0.5
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
    </xsl:template>
    
    <xsl:template match="tickets">
        <div class="tickets">
            <h2>Tickets</h2>
            <p>Total: <xsl:value-of select="count(descendant::ticket)"/>
            </p>
            <ul>
            	<li>
            		<h3>City-to-city</h3>
            		<ul>
		         		<xsl:for-each select="descendant::ticket[not(country)]">
		         		    <xsl:sort select="@points" data-type="number" order="ascending" />
		                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
		                </xsl:for-each>   			
            		</ul>
            	</li>
            	<li>
            		<h3>City-to-country</h3>
            		<ul>
		         		<xsl:for-each select="descendant::ticket[location][country]">
		                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
		                </xsl:for-each>   			
            		</ul>
            	</li>
            	<li>
            		<h3>Country-to-country</h3>
            		<ul>
		         		<xsl:for-each select="descendant::ticket[not(location)]">
		                    <li><xsl:apply-templates select="." mode="ticket.name"/></li>
		                </xsl:for-each>   			
            		</ul>
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
        <xsl:value-of select="name"/>
    </xsl:template>
    <xsl:template match="location[@id][not(name)]" mode="location.name">
        <xsl:value-of select="concat(ancestor::country[1]/name, ' (', @id, ')')"/>
    </xsl:template>
    <xsl:template match="country[@id]" mode="location.name">
        <xsl:value-of select="name"/>
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
</xsl:stylesheet>