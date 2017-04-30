<xsl:stylesheet 
	xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="#all" 
	version="2.0">

	<xsl:key name="ticket" match="/game/tickets/ticket" use="descendant::*[name() = ('location', 'country')]/@ref" />


	<xsl:template match="games[not(game/*[name() != 'title'])]" mode="html.header">
		<title>Games</title>
	</xsl:template>


	<xsl:template match="games[game/*[name() != 'title']]" mode="html.header">
        <title>TTR Analysis</title>
    </xsl:template>
    <xsl:template match="game" mode="html.header">
		<title>
			<xsl:value-of select="title" />
		</title>
	</xsl:template>


	<xsl:template match="games" mode="html.header.scripts html.header.style html.footer.scripts" />


	<xsl:template match="game" mode="html.header.scripts">
		<script type="text/javascript" src="{$normalised-path-to-js}vis.js" />
		<xsl:call-template name="generate-network-map">
			<xsl:with-param name="game" select="self::game" as="element()" />
		</xsl:call-template>
		<xsl:call-template name="generate-tickets-map">
			<xsl:with-param name="game" select="self::game" as="element()" />
		</xsl:call-template>
		<script type="text/javascript" src="{$normalised-path-to-js}game.js" />
		<xsl:choose>
			<xsl:when test="$static = 'false'">
				<script type="text/javascript">
                    <xsl:text>var gameId = "</xsl:text>
                    <xsl:value-of select="@id" />
                    <xsl:text>";</xsl:text>
                </script>
				<script type="text/javascript" src="{$normalised-path-to-js}update.js" />
			</xsl:when>
			<xsl:otherwise>
				<script type="text/javascript">function update(){};</script>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="game" mode="html.footer.scripts" />
	
	
	<xsl:template match="game" mode="html.header.style">
		<link type="text/css" href="{$normalised-path-to-js}vis.css" rel="stylesheet" />
		<link type="text/css" href="{$normalised-path-to-css}game.css" rel="stylesheet" />
	</xsl:template>
	
	
	<xsl:template match="games[game/*[name() != 'title']]" mode="html.body">
        <table>
            <tr>
                <th/>
                <xsl:for-each select="game">
                    <xsl:sort select="title" data-type="text" order="ascending"/>
                    <th class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                        <a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
                            <xsl:apply-templates select="." mode="game.name"/>
                        </a>
                    </th>
                </xsl:for-each>
            </tr>
            <tr class="odd">
                <td>Total locations</td>
                <xsl:apply-templates select="self::games" mode="games.compare.locations"/>
            </tr>
            <tr class="even">
                <td>Total route options</td>
				<!-- TODO: Calculate variations based on player numbers -->
                <xsl:apply-templates select="self::games" mode="games.compare.routes"/>
            </tr>
            <tr class="odd">
                <td>Total tickets</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets"/>
            </tr>
            <tr class="even">
                <td>Highest ticket value</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.value.max"/>
            </tr>
            <tr class="even">
                <td>Lowest ticket value</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.value.min"/>
            </tr>
            <tr class="odd">
                <td>Average (max) points per ticket</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.average.max"/>
            </tr>
            <tr class="even">
                <td>Average (min) points per ticket</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.average.min"/>
            </tr>
            <tr class="odd">
                <td>Shortest route length</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.shortest"/>
            </tr>
            <tr class="even">
                <td>Longest route length</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.longest"/>
            </tr>
            <tr class="odd">
                <td>Minimum number of players</td>
                <xsl:apply-templates select="self::games" mode="games.compare.players.max"/>
            </tr>
            <tr class="even">
                <td>Maximum number of players</td>
                <xsl:apply-templates select="self::games" mode="games.compare.players.min"/>
            </tr>
            <tr class="odd">
                <td>Tickets per location</td>
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.per.location"/>
            </tr>
            <tr class="even">
                <td>Tickets per route option</td>
				<!-- TODO: Calculate variations based on player numbers -->
                <xsl:apply-templates select="self::games" mode="games.compare.tickets.per.route"/>
            </tr>
            <tr class="odd">
                <td>Total single routes</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.single"/>
            </tr>
            <tr class="even">
                <td>Total double route options</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.double"/>
            </tr>
            <tr class="odd">
                <td>Ratio of single to double route options</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.ratio.single-double"/>
            </tr>
            <tr class="even">
                <td>Total tunnel route options</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.tunnels"/>
            </tr>
            <tr class="odd">
                <td>Total ferry route options</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.ferries"/>
            </tr>
            <tr class="even">
                <td>Total microlight route options</td>
                <xsl:apply-templates select="self::games" mode="games.compare.routes.microlights"/>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="games[game/*[name() != 'title']]" mode="   games.compare.tickets    games.compare.locations    games.compare.routes    games.compare.tickets.average.max    games.compare.tickets.value.max    games.compare.tickets.value.min    games.compare.routes.longest    games.compare.players.min    games.compare.players.max    games.compare.tickets.average.min    games.compare.tickets.per.location    games.compare.tickets.per.route    games.compare.routes.shortest   games.compare.routes.single   games.compare.routes.double   games.compare.routes.tunnels   games.compare.routes.ferries   games.compare.routes.microlights   games.compare.routes.ratio.single-double   ">
        <xsl:for-each select="game">
            <xsl:sort select="title" data-type="text" order="ascending"/>
            <td class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                <xsl:apply-templates select="self::game" mode="#current">
                    <xsl:with-param name="total-tickets" select="count(tickets/ticket)" as="xs:integer" tunnel="yes"/>
                    <xsl:with-param name="total-locations" select="count(map/locations/descendant::location[@id])" as="xs:integer" tunnel="yes"/>
                    <xsl:with-param name="total-routes" select="count(map/routes/descendant::route/(@colour | colour/@ref))" as="xs:integer" tunnel="yes"/>
                </xsl:apply-templates>
            </td>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets">
        <xsl:param name="total-tickets" as="xs:integer" tunnel="yes"/>
        <xsl:value-of select="$total-tickets"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.locations">
        <xsl:param name="total-locations" as="xs:integer" tunnel="yes"/>
        <xsl:value-of select="$total-locations"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes">
        <xsl:param name="total-routes" as="xs:integer" tunnel="yes"/>
        <xsl:value-of select="$total-routes"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.average.max">
        <xsl:param name="total-tickets" as="xs:integer" tunnel="yes"/>
        <xsl:variable name="total-max-points" select="if (tickets/ticket/(@points | */@points)) then sum(tickets/ticket/gw:get-max-ticket-points(.)) else 0" as="xs:integer"/>
        <xsl:value-of select="format-number($total-max-points div $total-tickets, '0.##')"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.average.min">
        <xsl:param name="total-tickets" as="xs:integer" tunnel="yes"/>
        <xsl:variable name="total-min-points" select="if (tickets/ticket/(@points | */@points)) then sum(tickets/ticket/gw:get-min-ticket-points(.)) else 0" as="xs:integer"/>
        <xsl:value-of select="format-number($total-min-points div $total-tickets, '0.##')"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.value.max">
        <xsl:for-each select="tickets/ticket">
            <xsl:sort select="gw:get-max-ticket-points(self::ticket)" data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="gw:get-max-ticket-points(self::ticket)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.value.min">
        <xsl:for-each select="tickets/ticket">
            <xsl:sort select="gw:get-min-ticket-points(self::ticket)" data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="gw:get-min-ticket-points(self::ticket)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.shortest">
        <xsl:for-each select="map/routes/descendant::route">
            <xsl:sort select="@length" data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="@length"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.longest">
        <xsl:for-each select="map/routes/descendant::route">
            <xsl:sort select="@length" data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="@length"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.players.min">
        <xsl:text>TODO</xsl:text>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.players.max">
        <xsl:text>TODO</xsl:text>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.per.location">
        <xsl:param name="total-tickets" as="xs:integer" tunnel="yes"/>
        <xsl:param name="total-locations" as="xs:integer" tunnel="yes"/>
        <xsl:value-of select="format-number(sum($total-tickets div $total-locations), '0.##')"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.per.route">
        <xsl:param name="total-tickets" as="xs:integer" tunnel="yes"/>
        <xsl:param name="total-routes" as="xs:integer" tunnel="yes"/>
        <xsl:value-of select="format-number(sum($total-tickets div $total-routes), '0.##')"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.single">
        <xsl:value-of select="count(map/routes/descendant::route[@colour])"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.double">
        <xsl:value-of select="count(map/routes/descendant::route[count(colour/@ref) = 2]/colour)"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.ratio.single-double">
        <xsl:variable name="total-single-routes" select="count(map/routes/descendant::route[@colour])" as="xs:integer"/>
        <xsl:variable name="total-double-routes" select="count(map/routes/descendant::route[count(colour/@ref) = 2]/colour)" as="xs:integer"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-single-routes, $total-double-routes)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($total-double-routes div $total-single-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.tunnels">
        <xsl:value-of select="count(map/routes/descendant::route[@tunnel = 'true']/(@colour | colour/@ref))"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.ferries">
        <xsl:value-of select="count(map/routes/descendant::route[@ferry &gt; 0]/(@colour | colour/@ref))"/>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.microlights">
        <xsl:value-of select="count(map/routes/descendant::route[@microlight = 'true']/(@colour | colour/@ref))"/>
    </xsl:template>
    <xsl:template match="games[not(game/*[name() != 'title'])]" mode="html.body">
		<h1>Games</h1>
		<ul>
			<xsl:for-each select="//game">
				<li>
					<a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
						<xsl:apply-templates select="." mode="game.name" />
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>


	<xsl:template match="game" mode="html.body">
		<h1>
			<xsl:value-of select="title" />
		</h1>
		<xsl:apply-templates select="self::*" mode="nav.page" />
		<xsl:apply-templates select="map/routes">
			<xsl:with-param name="colour" select="map/colours/colour" as="element()*" tunnel="yes" />
			<xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="map/locations">
			<xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="map/shortest-paths">
			<xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="tickets">
			<xsl:with-param name="game-id" select="@id" as="xs:string" tunnel="yes" />
		</xsl:apply-templates>
	</xsl:template>


	<xsl:template match="game" mode="nav.page">
		<li>
			<a href="#routes">Routes</a>
		</li>
		<li>
			<a href="#locations">Locations</a>
		</li>
		<li>
			<a href="#shortest-paths">Shortest Paths</a>
		</li>
		<li>
			<a href="#tickets">Tickets</a>
		</li>
	</xsl:template>


	<xsl:template match="locations">
		<xsl:param name="game-id" as="xs:string" tunnel="yes" />
		<xsl:param name="tickets" select="ticket" as="element()*" tunnel="no"/>
        <xsl:param name="destinations" as="element()*" tunnel="no"/>
        <section class="locations">
			<h2 id="locations">Locations</h2>
			<section>
                <h3 id="locations-summary">Summary</h3>
                <p>Total: <xsl:value-of select="count(descendant::location)"/>
                </p>
                <div class="multi-column">
                    <h4>All Locations</h4>
                    <ul class="multi-column">
                        <xsl:for-each select="descendant::location">
                            <xsl:sort select="if (name) then name else ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending"/>
                            <li>
                                <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                                    <xsl:value-of select="gw:get-location-name(.)"/>
                                </a>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </section>
			<section>
				<h3 id="locations-by-total-tickets">By Total Tickets</h3>
                <table>
					<tr>
                        <th>Location</th>
                        <th>Total Tickets</th>
                        <th>Max Points</th>
                        <th>Points per Ticket</th>
                    </tr>
					<xsl:for-each select="/game/map/locations/descendant::*[self::location[@id and name] or self::country[@id = $destinations/@id]]">
						<xsl:sort select="count(key('ticket', current()/@id))" data-type="number" order="descending"/>
                        <xsl:sort select="if (count(key('ticket', current()/@id)) = 0) then '0' else sum(key('ticket', current()/@id)/gw:get-max-ticket-points-for-location(self::ticket, current()/@id))" data-type="number" order="descending"/>
                        <xsl:sort select="name" data-type="text" order="ascending"/>
                        <xsl:variable name="destination-id" select="current()/@id" as="xs:string"/>
                        <xsl:variable name="destination-tickets" select="key('ticket', $destination-id)" as="element()*"/>
                        <xsl:variable name="total-tickets" select="count($destination-tickets)" as="xs:integer"/>
                        <xsl:variable name="max-points" select="if ($total-tickets = 0) then 0 else sum($destination-tickets/gw:get-max-ticket-points-for-location(self::ticket, $destination-id))" as="xs:integer"/>
                        <tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td>
                                <a href="{$normalised-path-to-html}/location/{$game-id}-{$destination-id}{$ext-html}">
                                    <xsl:value-of select="gw:get-location-name(self::*)"/>
                                </a>
                            </td>
						<td>
                                <xsl:value-of select="$total-tickets"/>
                            </td>
                            <td>
                                <xsl:value-of select="$max-points"/>
                            </td>
                            <td>
                                <xsl:value-of select="format-number(if ($max-points = 0) then 0 else $max-points div $total-tickets, '0.#')"/>
                            </td>
                        </tr>
					</xsl:for-each>
				</table>
			</section>
		<section>
                <h3 id="locations-by-max-ticket-points">By Max Ticket Points</h3>
                <table>
                    <tr>
                        <th>Location</th>
                        <th>Max Points</th>
                        <th>Points per Ticket</th>
                        <th>Total Tickets</th>
                    </tr>
                    <xsl:for-each-group select="$tickets" group-by="*[self::location or self::country]/@ref">
                        <xsl:sort select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" data-type="number" order="descending"/>
                        <xsl:sort select="count(current-group())" data-type="number" order="ascending"/>
                        <xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending"/>
                        <xsl:variable name="total-tickets" select="count(current-group())"/>
                        <xsl:variable name="max-points" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))"/>
                        <tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
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
            </section>
            <section>
                <h3 id="locations-by-points-per-ticket">By Points per Ticket</h3>
                <table>
                    <tr>
                        <th>Location</th>
                        <th>Points per Ticket</th>
                        <th>Total Tickets</th>
                        <th>Max Points</th>
                    </tr>
                    <xsl:for-each-group select="$tickets" group-by="*[self::location or self::country]/@ref">
                        <xsl:sort select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key())) div count(current-group())" data-type="number" order="descending"/>
                        <xsl:sort select="count(current-group())" data-type="number" order="descending"/>
                        <xsl:sort select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" data-type="number" order="descending"/>
                        <xsl:sort select="$destinations[@id = current-grouping-key()]/name" data-type="text" order="ascending"/>
                        <xsl:variable name="total-tickets" select="count(current-group())"/>
                        <xsl:variable name="max-points" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))"/>
                        <tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
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
            </section>
        </section>
	</xsl:template>


	<xsl:template match="routes" mode="#default script" priority="10">
		<xsl:next-match>
			<xsl:with-param name="routes" select="." as="element()" tunnel="no" />
		</xsl:next-match>
	</xsl:template>


	<xsl:template match="routes">
		<section class="routes">
			<h2 id="routes">Routes</h2>
			<section>
				<h3 id="route-lengths">Length</h3>
				<xsl:apply-templates select="self::routes" mode="routes.table">
					<xsl:with-param name="routes-filtered" select="route" as="element()*" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="double-routes">Double Routes</h3>
				<xsl:apply-templates select="self::routes" mode="routes.table">
					<xsl:with-param name="routes-filtered" select="route[count(colour) &gt; 1]" as="element()*" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="tunnel-routes">Tunnels</h3>
				<xsl:apply-templates select="self::routes" mode="routes.table">
					<xsl:with-param name="routes-filtered" select="route[@tunnel = 'true']" as="element()*" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="microlight-routes">Microlights</h3>
				<xsl:apply-templates select="self::routes" mode="routes.table">
					<xsl:with-param name="routes-filtered" select="route[@microlight = 'true']" as="element()*" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="ferry-routes">Ferries</h3>
				<xsl:apply-templates select="self::routes" mode="routes.table">
					<xsl:with-param name="routes-filtered" select="route[@ferry/number(.) &gt; 0]" as="element()*" tunnel="no" />
				</xsl:apply-templates>
			</section>
		</section>
	</xsl:template>


	<xsl:template match="routes" mode="routes.table">
		<xsl:param name="routes-filtered" as="element()*" tunnel="no" />
		<xsl:param name="colour" as="element()*" tunnel="yes" />

		<table>
			<tr>

				<!-- Segment length column heading -->
				<th>Length</th>

				<!-- Track colour column headings -->
				<xsl:for-each select="$colour">
					<th class="{@id}">
						<xsl:value-of select="name" />
					</th>
				</xsl:for-each>

				<!-- Segment length sub-total column heading -->
				<th>Total</th>
			</tr>
			<xsl:for-each-group select="self::routes/route" group-by="@length">
				<xsl:sort select="current-grouping-key()" order="descending" data-type="number" />

				<!-- 1 row per segment length -->
				<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">

					<!-- Row heading: the length of this segment -->
					<td>
						<xsl:value-of select="current-grouping-key()" />
					</td>

					<xsl:for-each select="$colour">
						<xsl:variable name="colour-id" select="@id" />

						<!-- The number of segments of this length, in this colour -->
						<td class="{$colour-id}">
							<xsl:value-of select="count($routes-filtered[@length = current-grouping-key()]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))" />
						</td>

					</xsl:for-each>

					<!-- The total number of segments of this length, in any colour -->
					<td>
						<xsl:value-of select="count($routes-filtered[@length = current-grouping-key()]/(@colour | colour/@ref))" />
					</td>

				</tr>

			</xsl:for-each-group>
			<xsl:variable name="total-unique-route-lengths" select="count(distinct-values(self::routes/route/@length))" />
			<tr class="total{if (sum($total-unique-route-lengths + 1) mod 2 = 0) then ' even' else ' odd'}">

				<td>Total</td>
				<xsl:for-each select="$colour">
					<xsl:variable name="colour-id" select="@id" />

					<!-- The total number of segments in this colour, of any length -->
					<td class="{$colour-id}">
						<xsl:value-of select="count($routes-filtered/(@colour[. = $colour-id] | colour[@ref = $colour-id]))" />
					</td>

				</xsl:for-each>

				<!-- The total number of segments in any colour, of any length -->
				<td>
					<xsl:value-of select="count($routes-filtered/(@colour | colour/@ref))" />
				</td>

			</tr>
			<tr class="value{if (sum($total-unique-route-lengths + 2) mod 2 = 0) then ' even' else ' odd'}">

				<td>Value</td>
				<xsl:for-each select="$colour">
					<xsl:variable name="colour-id" select="@id" />

					<!-- The total value of the segments in this colour -->
					<td class="{$colour-id}">
						<xsl:value-of select="sum(21 * count($routes-filtered[@length = '8']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 18 * count($routes-filtered[@length = '7']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 15 * count($routes-filtered[@length = '6']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 10 * count($routes-filtered[@length = '5']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 7 * count($routes-filtered[@length = '4']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 4 * count($routes-filtered[@length = '3']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + 2 * count($routes-filtered[@length = '2']/(@colour[. = $colour-id] | colour[@ref = $colour-id])) + count($routes-filtered[@length = '1']/(@colour[. = $colour-id] | colour[@ref = $colour-id])))" />
					</td>

				</xsl:for-each>

				<!-- The total value of all segments (of any length) in any colour -->
				<td>
					<xsl:value-of select="sum(21 * count($routes-filtered[@length = '8']) + 18 * count($routes-filtered[@length = '7']) + 15 * count($routes-filtered[@length = '6']) + 10 * count($routes-filtered[@length = '5']) + 7 * count($routes-filtered[@length = '4']) + 4 * count($routes-filtered[@length = '3']) + 2 * count($routes-filtered[@length = '2']) + count($routes-filtered[@length = '1']))" />
				</td>
			</tr>
		</table>
	</xsl:template>


	<xsl:template match="map/shortest-paths">
		<xsl:param name="game-id" as="xs:string" tunnel="yes" />
		<xsl:variable name="game" select="ancestor::game[1]" as="element()" />
		<xsl:variable name="paths" select="path" as="element()*" />
		<xsl:variable name="destinations" as="element()*">
			<xsl:for-each-group select="descendant::path/location" group-by="@ref">
				<xsl:sequence select="$game/map/locations/descendant::location[@id = current-grouping-key()]" />
			</xsl:for-each-group>
		</xsl:variable>
		<section class="shortest-paths">
			<h2 id="shortest-paths">Shortest Paths</h2>
			<section>
				<h3 id="shortest-paths-cross-referenced">Cross-referenced</h3>
				<table class="cross-reference">
					<tr>
						<th> </th>
						<xsl:for-each select="$destinations">
							<xsl:sort select="gw:get-location-name(self::*)" data-type="text" order="ascending" />
							<th class="destination {if (position() mod 2 = 0) then 'even' else 'odd'}">
								<span>
									<xsl:value-of select="gw:get-location-name(self::*)" />
								</span>
							</th>
						</xsl:for-each>
					</tr>
					<xsl:for-each select="$destinations">
						<xsl:sort select="gw:get-location-name(self::*)" data-type="text" order="ascending" />
						<xsl:variable name="from" select="." as="element()" />
						<xsl:variable name="paths-from" select="$paths[*/@ref = $from/@id]" as="element()*" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td class="destination">
								<a href="{$normalised-path-to-html}/location/{$game-id}-{$from/@id}{$ext-html}">
					                                    <xsl:value-of select="gw:get-location-name($from)"/>
					                                </a>
							</td>
							<xsl:for-each select="$destinations">
								<xsl:sort select="name" data-type="text" order="ascending" />
								<xsl:variable name="to" select="." as="element()" />
								<td class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
									<xsl:choose>
										<xsl:when test="$from/@id = $to/@id">
											<xsl:attribute name="class">self</xsl:attribute>
											<xsl:text>-</xsl:text>
										</xsl:when>
										<xsl:when test="not($paths-from[*/@ref = $to/@id])">
											<xsl:attribute name="class">empty</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$paths-from[*/@ref = $to/@id]/@distance" />
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</table>
			</section>
			<section>
				<h3 id="shortest-paths-by-distance">By Distance</h3>
				<ul class="zebra">
					<xsl:for-each-group select="path" group-by="@distance">
						<xsl:sort select="current-grouping-key()" data-type="number" order="ascending" />
						<li class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<h4> <xsl:value-of select="current-grouping-key()" /> Carriage<xsl:if test="current-grouping-key() != 1">s</xsl:if> (<xsl:value-of select="count(current-group())" /> paths)</h4>
							<ul class="multi-column">
								<xsl:for-each select="current-group()">
									<xsl:sort select="gw:get-path-start-name(self::path)" data-type="text" order="ascending"/>
						                               <xsl:sort select="gw:get-path-end-name(self::path)" data-type="text" order="ascending"/>
						                               <li>
										<xsl:apply-templates select="." mode="path.name" />
										<xsl:for-each select="ancestor::game[1]/tickets/ticket[location/@ref = current()/location[1]/@ref][location/@ref = current()/location[2]/@ref]">
											<span class="ticket">🎫</span>
											<span class="ticket-value">[<xsl:value-of select="@points" />]</span>
										</xsl:for-each>
									</li>
								</xsl:for-each>
							</ul>
						</li>
					</xsl:for-each-group>
				</ul>
			</section>
		</section>
	</xsl:template>


	<xsl:template match="tickets | locations" mode="#default script" priority="10">
		<xsl:variable name="tickets" select="ancestor::game[1]/tickets/ticket" as="element()*"/>
        <xsl:next-match>
			<xsl:with-param name="tickets" select="$tickets" as="element()*"/>
			<xsl:with-param name="destinations" as="element()*">
				<xsl:for-each-group select="$tickets/location" group-by="@ref">
					<xsl:sequence select="ancestor::game[1]/map/locations/descendant::location[@id = current-grouping-key()]" />
				</xsl:for-each-group>
				<xsl:for-each-group select="$tickets/country" group-by="@ref">
					<xsl:sequence select="ancestor::game[1]/map/locations/descendant::country[@id = current-grouping-key()]" />
				</xsl:for-each-group>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>


	<xsl:template match="tickets">
		<xsl:param name="game-id" as="xs:string" tunnel="yes" />
		<xsl:param name="tickets" select="ticket" as="element()*" tunnel="no" />
		<xsl:param name="destinations" as="element()*" tunnel="no" />
		<xsl:variable name="game" select="ancestor::game[1]" as="element()" />
		<section class="tickets">
			<h2 id="tickets">Tickets</h2>
			<section>
				<h3 id="tickets-summary">Summary</h3>
				<xsl:variable name="total-ticket-points-max" as="xs:integer?">
					<xsl:variable name="non-standard-tickets" as="element()*">
						<xsl:for-each select="$tickets[not(@points)]/*[@points]">
							<xsl:sort select="@points" data-type="number" order="descending" />
							<xsl:if test="position() = 1">
								<xsl:sequence select="self::*" />
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="sum($tickets/@points) + sum($non-standard-tickets/@points)" />
				</xsl:variable>
				<xsl:variable name="total-ticket-points-min" as="xs:integer?">
					<xsl:variable name="non-standard-tickets" as="element()*">
						<xsl:for-each select="$tickets[not(@points)]/*[@points]">
							<xsl:sort select="@points" data-type="number" order="ascending" />
							<xsl:if test="position() = 1">
								<xsl:sequence select="self::*" />
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="sum($tickets/@points) + sum($non-standard-tickets/@points)" />
				</xsl:variable>
				<p>Total tickets: <xsl:value-of select="count($tickets)" /> </p>
				<p>Total ticket points: <xsl:value-of select="$total-ticket-points-max" /> </p>
				<p>Average points per ticket: <xsl:value-of select="format-number(sum($total-ticket-points-max div count($tickets)), '###.##')" /> <xsl:if test="$total-ticket-points-max != $total-ticket-points-min"> (max), <xsl:value-of select="format-number(sum($total-ticket-points-min div count($tickets)), '###.##')" /> (min)</xsl:if> </p>
				<p>Total tickets per total locations (average): <xsl:value-of select="format-number(sum(count($tickets) div count(/game/map/locations/descendant::location[@id])), '0.#')" /> </p>
			</section>
			<section>
				<h3 id="tickets-by-points-frequency">Points Frequency</h3>
				<table>
					<tr>
						<th>Ticket Value</th>
						<th>Total Tickets</th>
					</tr>
					<xsl:for-each-group select="$tickets" group-by="
							if (@points) then
								@points
							else
								*/@points">
						<xsl:sort select="current-grouping-key()" data-type="number" order="ascending" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td>
								<xsl:value-of select="current-grouping-key()" />
							</td>
							<td>
								<xsl:value-of select="count(current-group())" />
							</td>
						</tr>
					</xsl:for-each-group>
				</table>
			</section>
			<section>
				<h3 id="tickets-cross-referenced">Cross-referenced</h3>
				<table class="cross-reference">
					<tr>
						<th> </th>
						<xsl:for-each select="$destinations">
							<xsl:sort select="name" data-type="text" order="ascending" />
							<th class="destination {if (position() mod 2 = 0) then 'even' else 'odd'}">
								<span>
									<xsl:value-of select="gw:get-location-name(self::*)" />
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
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td class="destination {if (position() mod 2 = 0) then 'even' else 'odd'}">
								<a href="{$normalised-path-to-html}/location/{$game-id}-{$from/@id}{$ext-html}">
                                    						<xsl:value-of select="gw:get-location-name($from)"/>
                                					</a>
							</td>
							<xsl:for-each select="$destinations">
								<xsl:sort select="name" data-type="text" order="ascending" />
								<xsl:variable name="to" select="." as="element()" />
								<xsl:variable name="odd" select="
										if (position() mod 2 = 0) then
											false()
										else
											true()" as="xs:boolean" />
								<td>
									<xsl:choose>
										<xsl:when test="$from/@id = $to/@id">
											<xsl:attribute name="class">self<xsl:value-of select="
													if ($odd = true()) then
														'odd'
													else
														'even'" /> </xsl:attribute>
											<xsl:text>-</xsl:text>
										</xsl:when>
										<xsl:when test="not($tickets-from[*/@ref = $to/@id])">
											<xsl:attribute name="class">empty<xsl:value-of select="
													if ($odd = true()) then
														'odd'
													else
														'even'" /> </xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">
												<xsl:value-of select="
														if ($odd = true()) then
															'odd'
														else
															'even'" />
											</xsl:attribute>
											<xsl:value-of select="sum($tickets-from[*/@ref = $to/@id]/@points) + sum($tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]/*[@ref = $to/@id]/@points) + sum($tickets-from[not(@points)][*[not(@points)]/@ref = $to/@id]/*[@ref = $from/@id]/@points)" />
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:for-each>
							<td>
								<xsl:value-of select="count($tickets-from)" />
							</td>
							<td>
								<xsl:variable name="max-points" as="element()*">
									<!-- city-to-city tickets -->
									<xsl:for-each select="$tickets-from[@points]">
										<points>
											<xsl:value-of select="@points" />
										</points>
									</xsl:for-each>
									<!-- dependency on this location -->
									<xsl:for-each select="$tickets-from[not(@points)][*[not(@points)]/@ref = $from/@id]">
										<!-- Find the destination with the highest points -->
										<xsl:for-each select="*[@points]">
											<xsl:sort select="@points" data-type="number" order="descending" />
											<xsl:if test="position() = 1">
												<points>
													<xsl:value-of select="@points" />
												</points>
											</xsl:if>
										</xsl:for-each>
									</xsl:for-each>
									<!--dpendency on another location -->
									<xsl:for-each select="$tickets-from[not(@points)]/*[@ref = $from/@id][@points]">
										<points>
											<xsl:value-of select="@points" />
										</points>
									</xsl:for-each>
								</xsl:variable>
								<xsl:value-of select="sum($max-points)" />
							</td>
						</tr>
					</xsl:for-each>
				</table>
			</section>
			<section>
				<h3 id="tickets-by-type">By Type</h3>
				<ul class="zebra">
					<li class="odd">
						<h4>Settlement-to-settlement</h4>
						<xsl:choose>
							<xsl:when test="descendant::ticket[not(country)]">
								<ul class="multi-column">
									<xsl:for-each select="descendant::ticket[not(country)]">
										<xsl:sort select="@points" data-type="number" order="ascending" />
										<xsl:sort select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" data-type="text" order="ascending"/>
                                        <li>
											<xsl:apply-templates select="." mode="ticket.name" />
										</li>
									</xsl:for-each>
								</ul>
							</xsl:when>
							<xsl:otherwise>
								<p class="none">[none]</p>
							</xsl:otherwise>
						</xsl:choose>
					</li>
					<li class="even">
						<h4>Settlement-to-region</h4>
						<xsl:choose>
							<xsl:when test="descendant::ticket[location][country]">
								<ul class="multi-column">
									<xsl:for-each select="descendant::ticket[location][country]">
										<xsl:sort select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" data-type="text" order="ascending"/>
                                        <li>
											<xsl:apply-templates select="." mode="ticket.name" />
										</li>
									</xsl:for-each>
								</ul>
							</xsl:when>
							<xsl:otherwise>
								<p class="none">[none]</p>
							</xsl:otherwise>
						</xsl:choose>
					</li>
					<li class="odd">
						<h4>Region-to-region</h4>
						<xsl:choose>
							<xsl:when test="descendant::ticket[not(location)]">
								<ul class="multi-column">
									<xsl:for-each select="descendant::ticket[not(location)]">
										<xsl:sort select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" data-type="text" order="ascending"/>
                                        <li>
											<xsl:apply-templates select="." mode="ticket.name" />
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
			</section>
		</section>
	</xsl:template>


	<xsl:template match="ticket[count(*[name() = ('location', 'country')]) = 2]" mode="ticket.name">
		<xsl:for-each select="*[name() = ('location', 'country')]">
            <xsl:sort select="gw:get-location-name(self::*)" data-type="text" order="ascending"/>
            <xsl:value-of select="gw:get-location-name(self::*)"/>
            <xsl:if test="position() = 1">
                <xsl:text> to </xsl:text>
            </xsl:if>
        </xsl:for-each>
		<xsl:value-of select="concat(' [', @points, ']')" />
	</xsl:template>


	<xsl:template match="ticket[count(*[name() = ('location', 'country')]) &gt; 2]" mode="ticket.name">
		<xsl:value-of select="gw:get-location-name(*[name() = ('location', 'country')][not(@points)])" />
		<xsl:text> to </xsl:text>
		<xsl:for-each select="*[name() = ('location', 'country')][@points]">
			<xsl:sort select="@points" data-type="number" order="ascending" />
			<xsl:value-of select="gw:get-location-name(.)" />
			<xsl:value-of select="concat(' [', @points, ']')" />
			<xsl:if test="position() != last()">
				<xsl:text> or </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<xsl:template match="path" mode="path.name">
		<xsl:param name="game-id" as="xs:string" tunnel="yes"/>
		<xsl:for-each select="location">
	            <xsl:sort select="gw:get-location-name(self::location)" data-type="text" order="ascending"/>
	            <a href="{$normalised-path-to-html}/location/{$game-id}-{@ref}{$ext-html}">
	                <xsl:value-of select="gw:get-location-name(self::location)"/>
	            </a>
	            <xsl:if test="position() = 1">
	                <xsl:text> to </xsl:text>
	            </xsl:if>
	        </xsl:for-each>
	</xsl:template>
</xsl:stylesheet>