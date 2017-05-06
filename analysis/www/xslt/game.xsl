<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:key match="/game/tickets/ticket" name="ticket" use="descendant::*[name() = ('location', 'country')]/@ref" />





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
		<script src="{$normalised-path-to-js}vis.js" type="text/javascript" />
		<xsl:call-template name="generate-network-map">
			<xsl:with-param as="element()" name="game" select="self::game" />
		</xsl:call-template>
		<xsl:call-template name="generate-tickets-map">
			<xsl:with-param as="element()" name="game" select="self::game" />
		</xsl:call-template>
		<script src="{$normalised-path-to-js}game.js" type="text/javascript" />
		<xsl:choose>
			<xsl:when test="$static = 'false'">
				<script type="text/javascript">
                    <xsl:text>var gameId = "</xsl:text>
                    <xsl:value-of select="@id" />
                    <xsl:text>";</xsl:text>
                </script>
				<script src="{$normalised-path-to-js}update.js" type="text/javascript" />
			</xsl:when>
			<xsl:otherwise>
				<script type="text/javascript">function update(){};</script>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>





	<xsl:template match="game" mode="html.footer.scripts" />





	<xsl:template match="game" mode="html.header.style">
		<link href="{$normalised-path-to-js}vis.css" rel="stylesheet" type="text/css" />
		<link href="{$normalised-path-to-css}game.css" rel="stylesheet" type="text/css" />
	</xsl:template>





	<xsl:template match="games[game/*[name() != 'title']]" mode="html.body">
		<table>
			<tr>
				<th />
				<xsl:for-each select="game">
					<xsl:sort data-type="number" order="ascending" select="players/@min" />
					<xsl:sort data-type="number" order="ascending" select="players/@max" />
					<xsl:sort data-type="number" order="ascending" select="players/@double-routes-min" />
					<xsl:sort data-type="text" order="ascending" select="title" />
					<th class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
						<a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
							<xsl:apply-templates mode="game.name" select="." />
						</a>
					</th>
				</xsl:for-each>
			</tr>
			<tr class="odd">
				<td>Total locations</td>
				<xsl:apply-templates mode="games.compare.locations" select="self::games" />
			</tr>
			<tr class="even">
				<td>Total route options</td>
				<!-- TODO: Calculate variations based on player numbers -->
				<xsl:apply-templates mode="games.compare.routes" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Total tickets</td>
				<xsl:apply-templates mode="games.compare.tickets" select="self::games" />
			</tr>
			<tr class="even">
				<td>Highest ticket value</td>
				<xsl:apply-templates mode="games.compare.tickets.value.max" select="self::games" />
			</tr>
			<tr class="even">
				<td>Lowest ticket value</td>
				<xsl:apply-templates mode="games.compare.tickets.value.min" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Average (max) points per ticket</td>
				<xsl:apply-templates mode="games.compare.tickets.average.max" select="self::games" />
			</tr>
			<tr class="even">
				<td>Average (min) points per ticket</td>
				<xsl:apply-templates mode="games.compare.tickets.average.min" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Shortest route length</td>
				<xsl:apply-templates mode="games.compare.routes.shortest" select="self::games" />
			</tr>
			<tr class="even">
				<td>Longest route length</td>
				<xsl:apply-templates mode="games.compare.routes.longest" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Minimum number of players</td>
				<xsl:apply-templates mode="games.compare.players.min" select="self::games" />
			</tr>
			<tr class="even">
				<td>Maximum number of players</td>
				<xsl:apply-templates mode="games.compare.players.max" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Tickets per location</td>
				<xsl:apply-templates mode="games.compare.tickets.per.location" select="self::games" />
			</tr>
			<tr class="even">
				<td>Tickets per route option</td>
				<!-- TODO: Calculate variations based on player numbers -->
				<xsl:apply-templates mode="games.compare.tickets.per.route" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Total single routes</td>
				<xsl:apply-templates mode="games.compare.routes.single" select="self::games" />
			</tr>
			<tr class="even">
				<td>Total double route options</td>
				<xsl:apply-templates mode="games.compare.routes.double" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Ratio of single to double route options</td>
				<xsl:apply-templates mode="games.compare.routes.ratio.single-double" select="self::games" />
			</tr>
			<tr class="even">
				<td>Total tunnel route options</td>
				<xsl:apply-templates mode="games.compare.routes.tunnels" select="self::games" />
			</tr>
			<tr class="odd">
				<td>Total ferry route options</td>
				<xsl:apply-templates mode="games.compare.routes.ferries" select="self::games" />
			</tr>
			<tr class="even">
				<td>Total microlight route options</td>
				<xsl:apply-templates mode="games.compare.routes.microlights" select="self::games" />
			</tr>
		<tr class="odd">
                <td>Ratio of route options to locations</td>
                <xsl:apply-templates mode="games.compare.routes.ratio.locations" select="self::games"/>
            </tr>
        </table>
	<xsl:variable name="min-players" as="xs:integer">
            <xsl:choose>
                <xsl:when test="game/players/@min">
                    <xsl:for-each select="game/players/@min">
                        <xsl:sort select="." data-type="number" order="ascending"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>2</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="max-players" as="xs:integer">
            <xsl:choose>
                <xsl:when test="game/players/@max">
                    <xsl:for-each select="game/players/@max">
                        <xsl:sort select="." data-type="number" order="descending"/>
                        <xsl:if test="position() = 1">
                            <xsl:value-of select="."/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$min-players"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="game-stats-by-player-number">
            <xsl:with-param name="players" select="$min-players" tunnel="yes" as="xs:integer"/>
            <xsl:with-param name="max-players" select="$max-players" as="xs:integer"/>
        </xsl:call-template>
    </xsl:template>
	
	
	<xsl:template name="game-stats-by-player-number">
        <xsl:param name="players" tunnel="yes" as="xs:integer"/>
        <xsl:param name="max-players" as="xs:integer"/>
        <h2>
            <xsl:value-of select="$players"/> Players</h2>
        <table>
            <tr>
                <th/>
                <xsl:for-each select="game[not($players &gt; players/@max/number(.))]">
                    <xsl:sort data-type="number" order="ascending" select="players/@min"/>
                    <xsl:sort data-type="number" order="ascending" select="players/@max"/>
                    <xsl:sort data-type="number" order="ascending" select="players/@double-routes-min"/>
                    <xsl:sort data-type="text" order="ascending" select="title"/>
                    <th class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                        <a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
                            <xsl:apply-templates mode="game.name" select="."/>
                        </a>
                    </th>
                </xsl:for-each>
            </tr>
            <tr class="odd">
                <td>Ratio of locations to players</td>
                <xsl:apply-templates mode="games.compare.locations.ratio.players" select="self::games"/>
            </tr>
            <tr class="even">
                <td>Total route options</td>
                <xsl:apply-templates mode="games.compare.routes" select="self::games"/>
            </tr>
            <tr class="odd">
                <td>Tickets per route option</td>
                <xsl:apply-templates mode="games.compare.tickets.per.route" select="self::games"/>
            </tr>
            <tr class="even">
                <td>Total single routes</td>
                <xsl:apply-templates mode="games.compare.routes.single" select="self::games"/>
            </tr>
            <tr class="odd">
                <td>Total double route options</td>
                <xsl:apply-templates mode="games.compare.routes.double" select="self::games"/>
            </tr>
            <tr class="even">
                <td>Total tunnel route options</td>
                <xsl:apply-templates mode="games.compare.routes.tunnels" select="self::games"/>
            </tr>
            <tr class="odd">
                <td>Total ferry route options</td>
                <xsl:apply-templates mode="games.compare.routes.ferries" select="self::games"/>
            </tr>
            <tr class="even">
                <td>Total microlight route options</td>
                <xsl:apply-templates mode="games.compare.routes.microlights" select="self::games"/>
            </tr>
            <tr class="odd">
                <td>Ratio of route options to locations</td>
                <xsl:apply-templates mode="games.compare.routes.ratio.locations" select="self::games"/>
            </tr>
            <tr class="even">
                <td>Ratio of tickets to players</td>
                <xsl:apply-templates mode="games.compare.tickets.ratio.players" select="self::games"/>
            </tr>
            <tr class="odd">
                <td>Ratio of route options to players</td>
                <xsl:apply-templates mode="games.compare.routes.ratio.players" select="self::games"/>
            </tr>
        </table>
        <xsl:if test="not(($players + 1) &gt; $max-players)">
            <xsl:call-template name="game-stats-by-player-number">
                <xsl:with-param name="players" select="$players + 1" as="xs:integer" tunnel="yes"/>
                <xsl:with-param name="max-players" select="$max-players"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
	
	
	<xsl:template match="games[game/*[name() != 'title']]" mode="         games.compare.players.min          games.compare.players.max            games.compare.tickets          games.compare.tickets.average.max          games.compare.tickets.value.max          games.compare.tickets.value.min          games.compare.tickets.average.min         games.compare.tickets.per.location          games.compare.tickets.per.route          games.compare.tickets.ratio.players      games.compare.routes          games.compare.routes.longest       games.compare.routes.shortest         games.compare.routes.single         games.compare.routes.double         games.compare.routes.tunnels         games.compare.routes.ferries         games.compare.routes.microlights         games.compare.routes.ratio.single-double      games.compare.routes.ratio.locations      games.compare.routes.ratio.players      games.compare.locations          games.compare.locations.ratio.players      ">
        <xsl:param name="players" select="0" as="xs:integer" tunnel="yes"/>
        <xsl:for-each select="game[not($players &gt; players/@max/number(.))]">
            <xsl:sort data-type="number" order="ascending" select="players/@min"/>
            <xsl:sort data-type="number" order="ascending" select="players/@max"/>
            <xsl:sort data-type="number" order="ascending" select="players/@double-routes-min"/>
            <xsl:sort data-type="text" order="ascending" select="title"/>
            <td class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                <xsl:apply-templates mode="#current" select="self::game">
                    <xsl:with-param as="xs:integer" name="total-tickets" select="count(tickets/ticket)" tunnel="yes"/>
                    <xsl:with-param as="xs:integer" name="total-locations" select="count(map/locations/descendant::location[@id])" tunnel="yes"/>
                    <xsl:with-param as="xs:integer" name="total-routes" tunnel="yes">
                        <xsl:choose>
                            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">
                                <xsl:value-of select="count(map/routes/descendant::route[(@colour | colour/@ref)])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="count(map/routes/descendant::route/(@colour | colour/@ref))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="players" select="$players" as="xs:integer" tunnel="yes"/>
                </xsl:apply-templates>
            </td>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets">
		<xsl:param as="xs:integer" name="total-tickets" tunnel="yes" />
		<xsl:value-of select="$total-tickets" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.locations">
		<xsl:param as="xs:integer" name="total-locations" tunnel="yes" />
		<xsl:value-of select="$total-locations" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes">
		<xsl:param as="xs:integer" name="total-routes" tunnel="yes" />
		<xsl:value-of select="$total-routes" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.average.max">
		<xsl:param as="xs:integer" name="total-tickets" tunnel="yes" />
		<xsl:variable as="xs:integer" name="total-max-points" select="
				if (tickets/ticket/(@points | */@points)) then
					sum(tickets/ticket/gw:get-max-ticket-points(.))
				else
					0" />
		<xsl:value-of select="format-number($total-max-points div $total-tickets, '0.##')" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.average.min">
		<xsl:param as="xs:integer" name="total-tickets" tunnel="yes" />
		<xsl:variable as="xs:integer" name="total-min-points" select="
				if (tickets/ticket/(@points | */@points)) then
					sum(tickets/ticket/gw:get-min-ticket-points(.))
				else
					0" />
		<xsl:value-of select="format-number($total-min-points div $total-tickets, '0.##')" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.value.max">
		<xsl:for-each select="tickets/ticket">
			<xsl:sort data-type="number" order="descending" select="gw:get-max-ticket-points(self::ticket)" />
			<xsl:if test="position() = 1">
				<xsl:value-of select="gw:get-max-ticket-points(self::ticket)" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.value.min">
		<xsl:for-each select="tickets/ticket">
			<xsl:sort data-type="number" order="ascending" select="gw:get-min-ticket-points(self::ticket)" />
			<xsl:if test="position() = 1">
				<xsl:value-of select="gw:get-min-ticket-points(self::ticket)" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.shortest">
		<xsl:for-each select="map/routes/descendant::route">
			<xsl:sort data-type="number" order="ascending" select="@length" />
			<xsl:if test="position() = 1">
				<xsl:value-of select="@length" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.longest">
		<xsl:for-each select="map/routes/descendant::route">
			<xsl:sort data-type="number" order="descending" select="@length" />
			<xsl:if test="position() = 1">
				<xsl:value-of select="@length" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.players.min">
		<xsl:value-of select="players/@min" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.players.max">
		<xsl:value-of select="players/@max" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.per.location">
		<xsl:param as="xs:integer" name="total-tickets" tunnel="yes" />
		<xsl:param as="xs:integer" name="total-locations" tunnel="yes" />
		<xsl:value-of select="format-number(sum($total-tickets div $total-locations), '0.##')" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.tickets.per.route">
		<xsl:param as="xs:integer" name="total-tickets" tunnel="yes" />
		<xsl:param as="xs:integer" name="total-routes" tunnel="yes" />
		<xsl:value-of select="format-number(sum($total-tickets div $total-routes), '0.##')" />
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.single">
		<xsl:param name="players" tunnel="yes" as="xs:integer?"/>
	<xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">
                <xsl:value-of select="$total-routes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(map/routes/descendant::route[@colour])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.double">
		<xsl:param name="players" tunnel="yes" as="xs:integer?"/>
	<xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">0</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(map/routes/descendant::route[count(colour/@ref) = 2]/colour)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.ratio.single-double">
		<xsl:variable as="xs:integer" name="total-single-routes" select="count(map/routes/descendant::route[@colour])" />
		<xsl:variable as="xs:integer" name="total-double-routes" select="count(map/routes/descendant::route[count(colour/@ref) = 2]/colour)" />
		<span class="ratio">
			<xsl:value-of select="gw:get-ratio($total-single-routes, $total-double-routes)" />
		</span>
		<xsl:text> </xsl:text>
		<span class="average">(<xsl:value-of select="format-number($total-double-routes div $total-single-routes, '0.#')" />)</span>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.tunnels">
		<xsl:param name="players" tunnel="yes" as="xs:integer"/>
	<xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">
                <xsl:value-of select="count(map/routes/descendant::route[@tunnel = 'true'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(map/routes/descendant::route[@tunnel = 'true']/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.ferries">
		<xsl:param name="players" tunnel="yes" as="xs:integer"/>
	<xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">
                <xsl:value-of select="count(map/routes/descendant::route[@ferry &gt; 0][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(map/routes/descendant::route[@ferry &gt; 0]/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.microlights">
		<xsl:param name="players" tunnel="yes" as="xs:integer"/>
	<xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; players/@double-routes-min/number(.)">
                <xsl:value-of select="count(map/routes/descendant::route[@microlight = 'true'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(map/routes/descendant::route[@microlight = 'true'][(@colour | colour/@ref)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
	
	
	<xsl:template match="game" mode="games.compare.routes.ratio.locations">
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-routes, $total-locations)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($total-locations div $total-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.locations.ratio.players">
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-locations, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-locations, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.routes.ratio.players">
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-routes, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="game" mode="games.compare.tickets.ratio.players">
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-tickets, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-tickets, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="games[not(game/*[name() != 'title'])]" mode="html.body">
		<h1>Games</h1>
		<ul>
			<xsl:for-each select="//game">
				<li>
					<a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
						<xsl:apply-templates mode="game.name" select="." />
					</a>
				</li>
			</xsl:for-each>
		</ul>
	</xsl:template>





	<xsl:template match="game" mode="html.body">
		<h1>
			<xsl:value-of select="title" />
		</h1>
		<xsl:apply-templates mode="nav.page" select="self::*" />
		<xsl:apply-templates select="map/routes">
			<xsl:with-param as="element()*" name="colour" select="map/colours/colour" tunnel="yes" />
			<xsl:with-param as="xs:string" name="game-id" select="@id" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="map/locations">
			<xsl:with-param as="xs:string" name="game-id" select="@id" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="map/shortest-paths">
			<xsl:with-param as="xs:string" name="game-id" select="@id" tunnel="yes" />
		</xsl:apply-templates>
		<xsl:apply-templates select="tickets">
			<xsl:with-param as="xs:string" name="game-id" select="@id" tunnel="yes" />
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
		<xsl:param as="xs:string" name="game-id" tunnel="yes" />
		<xsl:param as="element()*" name="tickets" select="ticket" tunnel="no" />
		<xsl:param as="element()*" name="destinations" tunnel="no" />
		<section class="locations">
			<h2 id="locations">Locations</h2>
			<section>
				<h3 id="locations-summary">Summary</h3>
				<p>Total: <xsl:value-of select="count(descendant::location)" /> </p>
				<div class="multi-column">
					<h4>All Locations</h4>
					<ul class="multi-column">
						<xsl:for-each select="descendant::location">
							<xsl:sort data-type="text" order="ascending" select="
									if (name) then
										name
									else
										ancestor::country[1]/concat(name, ' (', @id, ')')" />
							<li>
								<a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
									<xsl:value-of select="gw:get-location-name(.)" />
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
						<xsl:sort data-type="number" order="descending" select="count(key('ticket', current()/@id))" />
						<xsl:sort data-type="number" order="descending" select="
								if (count(key('ticket', current()/@id)) = 0) then
									'0'
								else
									sum(key('ticket', current()/@id)/gw:get-max-ticket-points-for-location(self::ticket, current()/@id))" />
						<xsl:sort data-type="text" order="ascending" select="name" />
						<xsl:variable as="xs:string" name="destination-id" select="current()/@id" />
						<xsl:variable as="element()*" name="destination-tickets" select="key('ticket', $destination-id)" />
						<xsl:variable as="xs:integer" name="total-tickets" select="count($destination-tickets)" />
						<xsl:variable as="xs:integer" name="max-points" select="
								if ($total-tickets = 0) then
									0
								else
									sum($destination-tickets/gw:get-max-ticket-points-for-location(self::ticket, $destination-id))" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td>
								<a href="{$normalised-path-to-html}/location/{$game-id}-{$destination-id}{$ext-html}">
									<xsl:value-of select="gw:get-location-name(self::*)" />
								</a>
							</td>
							<td>
								<xsl:value-of select="$total-tickets" />
							</td>
							<td>
								<xsl:value-of select="$max-points" />
							</td>
							<td>
								<xsl:value-of select="
										format-number(if ($max-points = 0) then
											0
										else
											$max-points div $total-tickets, '0.#')" />
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
					<xsl:for-each-group group-by="*[self::location or self::country]/@ref" select="$tickets">
						<xsl:sort data-type="number" order="descending" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" />
						<xsl:sort data-type="number" order="ascending" select="count(current-group())" />
						<xsl:sort data-type="text" order="ascending" select="$destinations[@id = current-grouping-key()]/name" />
						<xsl:variable name="total-tickets" select="count(current-group())" />
						<xsl:variable name="max-points" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td>
								<xsl:choose>
									<xsl:when test="$destinations[@id = current-grouping-key()]">
										<a href="{$normalised-path-to-html}/location/{$game-id}-{current-grouping-key()}{$ext-html}">
											<xsl:value-of select="gw:get-location-name($destinations[@id = current-grouping-key()])" />
										</a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="current-grouping-key()" />
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:value-of select="$max-points" />
							</td>
							<td>
								<xsl:value-of select="format-number($max-points div $total-tickets, '0.#')" />
							</td>
							<td>
								<xsl:value-of select="$total-tickets" />
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
					<xsl:for-each-group group-by="*[self::location or self::country]/@ref" select="$tickets">
						<xsl:sort data-type="number" order="descending" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key())) div count(current-group())" />
						<xsl:sort data-type="number" order="descending" select="count(current-group())" />
						<xsl:sort data-type="number" order="descending" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" />
						<xsl:sort data-type="text" order="ascending" select="$destinations[@id = current-grouping-key()]/name" />
						<xsl:variable name="total-tickets" select="count(current-group())" />
						<xsl:variable name="max-points" select="sum(current-group()/gw:get-max-ticket-points-for-location(self::ticket, current-grouping-key()))" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td>
								<xsl:choose>
									<xsl:when test="$destinations[@id = current-grouping-key()]">
										<a href="{$normalised-path-to-html}/location/{$game-id}{current-grouping-key()}{$ext-html}">
											<xsl:value-of select="gw:get-location-name($destinations[@id = current-grouping-key()])" />
										</a>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="current-grouping-key()" />
									</xsl:otherwise>
								</xsl:choose>
							</td>
							<td>
								<xsl:value-of select="format-number($max-points div $total-tickets, '0.#')" />
							</td>
							<td>
								<xsl:value-of select="$total-tickets" />
							</td>
							<td>
								<xsl:value-of select="$max-points" />
							</td>
						</tr>
					</xsl:for-each-group>
				</table>
			</section>
		</section>
	</xsl:template>





	<xsl:template match="routes" mode="#default script" priority="10">
		<xsl:next-match>
			<xsl:with-param as="element()" name="routes" select="." tunnel="no" />
		</xsl:next-match>
	</xsl:template>





	<xsl:template match="routes">
		<section class="routes">
			<h2 id="routes">Routes</h2>
			<section>
				<h3 id="route-lengths">Length</h3>
				<xsl:apply-templates mode="routes.table" select="self::routes">
					<xsl:with-param as="element()*" name="routes-filtered" select="route" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="double-routes">Double Routes</h3>
				<xsl:apply-templates mode="routes.table" select="self::routes">
					<xsl:with-param as="element()*" name="routes-filtered" select="route[count(colour) &gt; 1]" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="tunnel-routes">Tunnels</h3>
				<xsl:apply-templates mode="routes.table" select="self::routes">
					<xsl:with-param as="element()*" name="routes-filtered" select="route[@tunnel = 'true']" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="microlight-routes">Microlights</h3>
				<xsl:apply-templates mode="routes.table" select="self::routes">
					<xsl:with-param as="element()*" name="routes-filtered" select="route[@microlight = 'true']" tunnel="no" />
				</xsl:apply-templates>
			</section>
			<section>
				<h3 id="ferry-routes">Ferries</h3>
				<xsl:apply-templates mode="routes.table" select="self::routes">
					<xsl:with-param as="element()*" name="routes-filtered" select="route[@ferry/number(.) &gt; 0]" tunnel="no" />
				</xsl:apply-templates>
			</section>
		</section>
	</xsl:template>





	<xsl:template match="routes" mode="routes.table">
		<xsl:param as="element()*" name="routes-filtered" tunnel="no" />
		<xsl:param as="element()*" name="colour" tunnel="yes" />

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
			<xsl:for-each-group group-by="@length" select="self::routes/route">
				<xsl:sort data-type="number" order="descending" select="current-grouping-key()" />

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
		<xsl:param as="xs:string" name="game-id" tunnel="yes" />
		<xsl:variable as="element()" name="game" select="ancestor::game[1]" />
		<xsl:variable as="element()*" name="paths" select="path" />
		<xsl:variable as="element()*" name="destinations">
			<xsl:for-each-group group-by="@ref" select="descendant::path/location">
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
							<xsl:sort data-type="text" order="ascending" select="gw:get-location-name(self::*)" />
							<th class="destination {if (position() mod 2 = 0) then 'even' else 'odd'}">
								<span>
									<xsl:value-of select="gw:get-location-name(self::*)" />
								</span>
							</th>
						</xsl:for-each>
					</tr>
					<xsl:for-each select="$destinations">
						<xsl:sort data-type="text" order="ascending" select="gw:get-location-name(self::*)" />
						<xsl:variable as="element()" name="from" select="." />
						<xsl:variable as="element()*" name="paths-from" select="$paths[*/@ref = $from/@id]" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td class="destination">
								<a href="{$normalised-path-to-html}/location/{$game-id}-{$from/@id}{$ext-html}">
									<xsl:value-of select="gw:get-location-name($from)" />
								</a>
							</td>
							<xsl:for-each select="$destinations">
								<xsl:sort data-type="text" order="ascending" select="name" />
								<xsl:variable as="element()" name="to" select="." />
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
					<xsl:for-each-group group-by="@distance" select="path">
						<xsl:sort data-type="number" order="ascending" select="current-grouping-key()" />
						<li class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<h4> <xsl:value-of select="current-grouping-key()" /> Carriage<xsl:if test="current-grouping-key() != 1">s</xsl:if> (<xsl:value-of select="count(current-group())" /> paths)</h4>
							<ul class="multi-column">
								<xsl:for-each select="current-group()">
									<xsl:sort data-type="text" order="ascending" select="gw:get-path-start-name(self::path)" />
									<xsl:sort data-type="text" order="ascending" select="gw:get-path-end-name(self::path)" />
									<li>
										<xsl:apply-templates mode="path.name" select="." />
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
		<xsl:variable as="element()*" name="tickets" select="ancestor::game[1]/tickets/ticket" />
		<xsl:next-match>
			<xsl:with-param as="element()*" name="tickets" select="$tickets" />
			<xsl:with-param as="element()*" name="destinations">
				<xsl:for-each-group group-by="@ref" select="$tickets/location">
					<xsl:sequence select="ancestor::game[1]/map/locations/descendant::location[@id = current-grouping-key()]" />
				</xsl:for-each-group>
				<xsl:for-each-group group-by="@ref" select="$tickets/country">
					<xsl:sequence select="ancestor::game[1]/map/locations/descendant::country[@id = current-grouping-key()]" />
				</xsl:for-each-group>
			</xsl:with-param>
		</xsl:next-match>
	</xsl:template>





	<xsl:template match="tickets">
		<xsl:param as="xs:string" name="game-id" tunnel="yes" />
		<xsl:param as="element()*" name="tickets" select="ticket" tunnel="no" />
		<xsl:param as="element()*" name="destinations" tunnel="no" />
		<xsl:variable as="element()" name="game" select="ancestor::game[1]" />
		<section class="tickets">
			<h2 id="tickets">Tickets</h2>
			<section>
				<h3 id="tickets-summary">Summary</h3>
				<xsl:variable as="xs:integer?" name="total-ticket-points-max">
					<xsl:variable as="element()*" name="non-standard-tickets">
						<xsl:for-each select="$tickets[not(@points)]/*[@points]">
							<xsl:sort data-type="number" order="descending" select="@points" />
							<xsl:if test="position() = 1">
								<xsl:sequence select="self::*" />
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="sum($tickets/@points) + sum($non-standard-tickets/@points)" />
				</xsl:variable>
				<xsl:variable as="xs:integer?" name="total-ticket-points-min">
					<xsl:variable as="element()*" name="non-standard-tickets">
						<xsl:for-each select="$tickets[not(@points)]/*[@points]">
							<xsl:sort data-type="number" order="ascending" select="@points" />
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
					<xsl:for-each-group group-by="
							if (@points) then
								@points
							else
								*/@points" select="$tickets">
						<xsl:sort data-type="number" order="ascending" select="current-grouping-key()" />
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
							<xsl:sort data-type="text" order="ascending" select="name" />
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
						<xsl:sort data-type="text" order="ascending" select="name" />
						<xsl:variable as="element()" name="from" select="." />
						<xsl:variable as="element()*" name="tickets-from" select="$tickets[*/@ref = $from/@id]" />
						<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
							<td class="destination {if (position() mod 2 = 0) then 'even' else 'odd'}">
								<a href="{$normalised-path-to-html}/location/{$game-id}-{$from/@id}{$ext-html}">
									<xsl:value-of select="gw:get-location-name($from)" />
								</a>
							</td>
							<xsl:for-each select="$destinations">
								<xsl:sort data-type="text" order="ascending" select="name" />
								<xsl:variable as="element()" name="to" select="." />
								<xsl:variable as="xs:boolean" name="odd" select="
										if (position() mod 2 = 0) then
											false()
										else
											true()" />
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
								<xsl:variable as="element()*" name="max-points">
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
											<xsl:sort data-type="number" order="descending" select="@points" />
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
										<xsl:sort data-type="number" order="ascending" select="@points" />
										<xsl:sort data-type="text" order="ascending" select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" />
										<li>
											<xsl:apply-templates mode="ticket.name" select="." />
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
										<xsl:sort data-type="text" order="ascending" select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" />
										<li>
											<xsl:apply-templates mode="ticket.name" select="." />
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
										<xsl:sort data-type="text" order="ascending" select="string-join(gw:get-sorted-ticket-locations(self::ticket), ';')" />
										<li>
											<xsl:apply-templates mode="ticket.name" select="." />
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
			<xsl:sort data-type="text" order="ascending" select="gw:get-location-name(self::*)" />
			<xsl:value-of select="gw:get-location-name(self::*)" />
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
			<xsl:sort data-type="number" order="ascending" select="@points" />
			<xsl:value-of select="gw:get-location-name(.)" />
			<xsl:value-of select="concat(' [', @points, ']')" />
			<xsl:if test="position() != last()">
				<xsl:text> or </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>





	<xsl:template match="path" mode="path.name">
		<xsl:param as="xs:string" name="game-id" tunnel="yes" />
		<xsl:for-each select="location">
			<xsl:sort data-type="text" order="ascending" select="gw:get-location-name(self::location)" />
			<a href="{$normalised-path-to-html}/location/{$game-id}-{@ref}{$ext-html}">
				<xsl:value-of select="gw:get-location-name(self::location)" />
			</a>
			<xsl:if test="position() = 1">
				<xsl:text> to </xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>