<xsl:stylesheet 
	xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="#all" 
	version="2.0">
    
	<xsl:template match="games" mode="html.header">
        <title>Games</title>
    </xsl:template>
    
	<xsl:template match="game" mode="html.header">
        <title>
            <xsl:value-of select="title"/>
        </title>
        <script type="text/javascript" src="{$normalised-path-to-js}jquery.min.js"/>
        <script type="text/javascript" src="{$normalised-path-to-js}vis.js"/>
        <script type="text/javascript" src="{$normalised-path-to-js}game.js"/>
        <link type="text/css" href="{$normalised-path-to-js}vis.css" rel="stylesheet"/>
        <link type="text/css" href="{$normalised-path-to-css}game.css" rel="stylesheet"/>
    </xsl:template>
    
	<xsl:template match="games" mode="html.body">
        <h1>Games</h1>
        <ul>
            <xsl:for-each select="//game">
                <li>
                    <a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
                        <xsl:apply-templates select="." mode="game.name"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
	<xsl:template match="game" mode="html.body">
        <h1>
            <xsl:value-of select="title"/>
        </h1>
        <xsl:apply-templates select="self::*" mode="nav.page"/>
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
        <div class="scripts">
            <xsl:call-template name="generate-network-map">
                <xsl:with-param name="game" select="self::game" as="element()"/>
            </xsl:call-template>
            <xsl:call-template name="generate-tickets-map">
                <xsl:with-param name="game" select="self::game" as="element()"/>
            </xsl:call-template>
        </div>
    </xsl:template>
    
	<xsl:template match="game" mode="nav.page">
		<li><a href="#routes">Routes</a></li>
		<li><a href="#locations">Locations</a></li>
		<li><a href="#shortest-paths">Shortest Paths</a></li>
		<li><a href="#tickets">Tickets</a></li>
    </xsl:template>
    
	<xsl:template match="locations">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <div id="locations" class="locations">
            <h2>Locations</h2>
            <p>Total: <xsl:value-of select="count(descendant::location)"/>
            </p>
            <ul>
                <xsl:for-each select="descendant::location">
                    <xsl:sort select="        if (name) then         name        else         ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending"/>
                    <li>
                        <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                            <xsl:value-of select="gw:get-location-name(.)"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    
	<xsl:template match="routes" mode="#default script" priority="10">
        <xsl:next-match>
            <xsl:with-param name="routes" select="." as="element()"/>
        </xsl:next-match>
    </xsl:template>
    
	<xsl:template match="routes">
        <xsl:param name="colour" as="element()*" tunnel="yes"/>
        <xsl:param name="routes" as="element()" tunnel="no"/>
        <div id="routes" class="routes">
            <h2>Routes</h2>
            <h3>Network</h3>
            <div id="routes" class="network-visualisation"/>
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
                            <xsl:value-of select="sum(21 * count($routes/route[@length = '8']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 18 * count($routes/route[@length = '7']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 15 * count($routes/route[@length = '6']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 10 * count($routes/route[@length = '5']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 7 * count($routes/route[@length = '4']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 4 * count($routes/route[@length = '3']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 2 * count($routes/route[@length = '2']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + count($routes/route[@length = '1']/(@colour[. = $colour-id] | colour[@ref = $colour-id])))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="sum(21 * count($routes/route[@length = '8']) + 18 * count($routes/route[@length = '7']) + 15 * count($routes/route[@length = '6']) + 10 * count($routes/route[@length = '5']) + 7 * count($routes/route[@length = '4']) + 4 * count($routes/route[@length = '3']) + 2 * count($routes/route[@length = '2']) + count($routes/route[@length = '1']))"/>
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
                                <xsl:value-of select="count(current-group()[@ferry/number(.) &gt; 0]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                            </td>
                        </xsl:for-each>
                        <td>
                            <xsl:value-of select="count(current-group()[@ferry/number(.) &gt; 0]/(@colour | colour/@ref))"/>
                        </td>
                    </tr>
                </xsl:for-each-group>
                <tr>
                    <td>Total</td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count($routes/route[@ferry/number(.) &gt; 0]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count($routes/route[@ferry/number(.) &gt; 0]/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </table>
        </div>
    </xsl:template>
    
	<xsl:template match="map/shortest-paths">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <xsl:variable name="game" select="ancestor::game[1]" as="element()"/>
        <xsl:variable name="paths" select="path" as="element()*"/>
        <xsl:variable name="destinations" as="element()*">
            <xsl:for-each-group select="descendant::path/location" group-by="@ref">
                <xsl:copy-of select="$game/map/locations/descendant::*[name() = ('location', 'country')][@id = current-grouping-key()]"/>
            </xsl:for-each-group>
        </xsl:variable>
        <div id="shortest-paths" class="shortest-paths">
            <h2>Shortest Paths</h2>
            <table class="cross-reference">
                <tr>
                    <th> </th>
                    <xsl:for-each select="$destinations">
                        <xsl:sort select="name" data-type="text" order="ascending"/>
                        <th class="destination">
                            <span>
                                <xsl:value-of select="gw:get-location-name(self::*)"/>
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
                            <xsl:value-of select="gw:get-location-name($from)"/>
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
    
	<xsl:template match="tickets" mode="#default script" priority="10">
        <xsl:next-match>
            <xsl:with-param name="tickets" select="ticket" as="element()*"/>
            <xsl:with-param name="destinations" as="element()*">
                <xsl:for-each-group select="descendant::ticket/location" group-by="@ref">
                    <xsl:copy-of select="ancestor::game[1]/map/locations/descendant::location[@id = current-grouping-key()]"/>
                </xsl:for-each-group>
                <xsl:for-each-group select="descendant::ticket/country" group-by="@ref">
                    <xsl:copy-of select="ancestor::game[1]/map/locations/descendant::country[@id = current-grouping-key()]"/>
                </xsl:for-each-group>
            </xsl:with-param>
        </xsl:next-match>
    </xsl:template>
    
	<xsl:template match="tickets">
        <xsl:param name="game-id" as="xs:string" tunnel="yes"/>
        <xsl:param name="tickets" select="ticket" as="element()*" tunnel="no"/>
        <xsl:param name="destinations" as="element()*" tunnel="no"/>
        <xsl:variable name="game" select="ancestor::game[1]" as="element()"/>
        <div id="tickets" class="tickets">
            <h2>Tickets</h2>
            <p>Total: <xsl:value-of select="count(descendant::ticket)"/>
            </p>
            <div id="ticket-distribution" class="network-visualisation"/>
            <table class="cross-reference">
                <tr>
                    <th> </th>
                    <xsl:for-each select="$destinations">
                        <xsl:sort select="name" data-type="text" order="ascending"/>
                        <th class="destination">
                            <span>
                                <xsl:value-of select="gw:get-location-name(self::*)"/>
                            </span>
                        </th>
                    </xsl:for-each>
                    <th class="total">Total Tickets</th>
                    <th class="total">Max Points</th>
                </tr>
                <xsl:for-each select="$destinations">
                    <xsl:sort select="name" data-type="text" order="ascending"/>
                    <xsl:variable name="from" select="." as="element()"/>
                    <xsl:variable name="tickets-from" select="$tickets[*/@ref = $from/@id]" as="element()*"/>
                    <tr>
                        <td class="destination">
                            <xsl:value-of select="gw:get-location-name($from)"/>
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
                                    <xsl:when test="not($tickets-from[*/@ref = $to/@id])">
                                        <xsl:attribute name="class">empty</xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="sum($tickets-from[*/@ref = $to/@id]/@points) + sum($tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]/*[@ref = $to/@id]/@points) + sum($tickets-from[not(@points)][*[not(@points)]/@ref = $to/@id]/*[@ref = $from/@id]/@points)"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </xsl:for-each>
                        <td>
                            <xsl:value-of select="count($tickets-from)"/>
                        </td>
                        <td>
                            <xsl:variable name="max-points" as="element()*">
								<!-- city-to-city tickets -->
                                <xsl:for-each select="$tickets-from[@points]">
                                    <points>
                                        <xsl:value-of select="@points"/>
                                    </points>
                                </xsl:for-each>
								<!-- dependency on this location -->
                                <xsl:for-each select="$tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]">
									<!-- Find the destination with the highest points -->
                                    <xsl:for-each select="*[@points]">
                                        <xsl:sort select="@points" data-type="number" order="descending"/>
                                        <xsl:if test="position() = 1">
                                            <points>
                                                <xsl:value-of select="@points"/>
                                            </points>
                                        </xsl:if>
                                    </xsl:for-each>
                                </xsl:for-each>
								<!--dpendency on another location -->
                                <xsl:for-each select="$tickets-from[not(@points)]/*[@ref = $from/@id][@points]">
                                    <points>
                                        <xsl:value-of select="@points"/>
                                    </points>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:value-of select="sum($max-points)"/>
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
                    <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                    <xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending"/>
                    <xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending"/>
                    <xsl:variable name="total-tickets" select="count(current-group())"/>
                    <xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))"/>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$destinations[@id = current-grouping-key()]">
                                    <a href="{$normalised-path-to-html}/location/{$game-id}-{current-grouping-key()}{$ext-html}">
                                        <xsl:value-of select="gw:get-location-name($destinations[@id = current-grouping-key()])"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:value-of select="$total-tickets"/>
                        </td>
                        <td>
                            <xsl:value-of select="$max-points"/>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($max-points div $total-tickets, '0.#')"/>
                        </td>
                    </tr>
                </xsl:for-each-group>
                <xsl:for-each select="ancestor::game[1]/map/locations/descendant::location[not(@id = $destinations/@id)][not(ancestor::country[1]/@id = $destinations/@id)]">
                    <tr>
                        <td>
                            <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                                <xsl:value-of select="gw:get-location-name(.)"/>
                            </a>
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
                    <xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending"/>
                    <xsl:sort select="count(current-group())" data-type="number" order="ascending"/>
                    <xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending"/>
                    <xsl:variable name="total-tickets" select="count(current-group())"/>
                    <xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))"/>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$destinations[@id = current-grouping-key()]">
                                    <a href="{$normalised-path-to-html}/location/{$game-id}-{current-grouping-key()}{$ext-html}">
                                        <xsl:value-of select="gw:get-location-name($destinations[@id = current-grouping-key()])"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:value-of select="$max-points"/>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($max-points div $total-tickets, '0.#')"/>
                        </td>
                        <td>
                            <xsl:value-of select="$total-tickets"/>
                        </td>
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
                    <xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key())) div count(current-group())" data-type="number" order="descending"/>
                    <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                    <xsl:sort select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))" data-type="number" order="descending"/>
                    <xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending"/>
                    <xsl:variable name="total-tickets" select="count(current-group())"/>
                    <xsl:variable name="max-points" select="sum(current-group()/gw:getMaxPoints(self::ticket, current-grouping-key()))"/>
                    <tr>
                        <td>
                            <xsl:choose>
                                <xsl:when test="$destinations[@id = current-grouping-key()]">
                                    <a href="{$normalised-path-to-html}/location/{$game-id}{current-grouping-key()}{$ext-html}">
                                        <xsl:value-of select="gw:get-location-name($destinations[@id = current-grouping-key()])"/>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td>
                            <xsl:value-of select="format-number($max-points div $total-tickets, '0.#')"/>
                        </td>
                        <td>
                            <xsl:value-of select="$total-tickets"/>
                        </td>
                        <td>
                            <xsl:value-of select="$max-points"/>
                        </td>
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
                                    <xsl:sort select="@points" data-type="number" order="ascending"/>
                                    <li>
                                        <xsl:apply-templates select="." mode="ticket.name"/>
                                    </li>
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
                                    <li>
                                        <xsl:apply-templates select="." mode="ticket.name"/>
                                    </li>
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
                                    <li>
                                        <xsl:apply-templates select="." mode="ticket.name"/>
                                    </li>
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
    
	<xsl:template match="ticket[count(*[name() = ('location', 'country')]) = 2]" mode="ticket.name">
        <xsl:value-of select="gw:get-location-name(*[name() = ('location', 'country')][1])"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="gw:get-location-name(*[name() = ('location', 'country')][2])"/>
        <xsl:value-of select="concat(' [', @points, ']')"/>
    </xsl:template>
    
	<xsl:template match="ticket[count(*[name() = ('location', 'country')]) &gt; 2]" mode="ticket.name">
        <xsl:value-of select="gw:get-location-name(*[name() = ('location', 'country')][not(@points)])"/>
        <xsl:text> to </xsl:text>
        <xsl:for-each select="*[name() = ('location', 'country')][@points]">
            <xsl:sort select="@points" data-type="number" order="ascending"/>
            <xsl:value-of select="gw:get-location-name(.)"/>
            <xsl:value-of select="concat(' [', @points, ']')"/>
            <xsl:if test="position() != last()">
                <xsl:text> or </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
	<xsl:template match="path" mode="path.name">
        <xsl:value-of select="gw:get-location-name(location[1])"/>
        <xsl:text> to </xsl:text>
        <xsl:value-of select="gw:get-location-name(location[2])"/>
    </xsl:template>
	
</xsl:stylesheet>