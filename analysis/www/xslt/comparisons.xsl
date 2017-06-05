<xsl:stylesheet xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    <xsl:variable name="comparisons" as="document-node()">
        <xsl:document>
            <comparisons>
                <compare id="players-min" players="false">
                    <label>Minimum number of players</label>
                </compare>
                <compare id="players-max" players="false">
                    <label>Maximum number of players</label>
                </compare>
                <compare id="locations-total" players="false">
                    <label>Total locations</label>
                </compare>
                <compare id="locations-ratio-to-players" overview="false">
                    <label>Ratio of locations to players</label>
                </compare>
                <compare id="route-options-total">
                    <label>Total route options</label>
                </compare>
                <compare id="route-options-ratio-to-players" overview="false">
                    <label>Ratio of route options to players</label>
                </compare>
                <compare id="route-options-ratio-to-locations" overview="false">
                    <label>Ratio of route options to locations</label>
                </compare>
                <compare id="route-options-single-total" overview="false">
                    <label>Total single route options</label>
                </compare>
                <compare id="route-options-double-total" overview="false">
                    <label>Total double route options</label>
                </compare>
                <compare id="route-options-ratio-single-to-double" players="false">
                    <label>Ratio of single to double route options</label>
                </compare>
                <compare id="routes-shortest" players="false">
                    <label>Shortest route length</label>
                </compare>
                <compare id="routes-longest" players="false">
                    <label>Longest route length</label>
                </compare>
                <compare id="route-options-tunnel-total" overview="false">
                    <label>Total tunnel route options</label>
                </compare>
                <compare id="route-options-ferry-total" overview="false">
                    <label>Total ferry route options</label>
                </compare>
                <compare id="route-options-microlight-total" overview="false">
                    <label>Total microlight route options</label>
                </compare>
                <compare id="tickets-total" players="false">
                    <label>Total tickets</label>
                </compare>
                <compare id="tickets-ratio-to-players" overview="false">
                    <label>Ratio of tickets to players</label>
                </compare>
                <compare id="tickets-value-min" players="false">
                    <label>Lowest ticket value</label>
                </compare>
                <compare id="tickets-value-max" players="false">
                    <label>Highest ticket value</label>
                </compare>
                <compare id="tickets-points-average-max" players="false">
                    <label>Average (max) points per ticket</label>
                </compare>
                <compare id="tickets-points-average-min" players="false">
                    <label>Average (min) points per ticket</label>
                </compare>
                <compare id="tickets-per-location" players="false">
                    <label>Tickets per location</label>
                </compare>
                <compare id="tickets-per-route-option" overview="false">
                    <label>Tickets per route option</label>
                </compare>
            </comparisons>
        </xsl:document>
    </xsl:variable>
    <xsl:template name="all-players">
        <xsl:param name="games" as="element()*" tunnel="yes"/>
        <xsl:param name="min-players" as="xs:integer?" tunnel="no"/>
        <xsl:param name="max-players" as="xs:integer?" tunnel="no"/>
        <table>
            <tr>
                <th/>
                <xsl:for-each select="$games">
                    <xsl:sort data-type="number" order="ascending" select="players/@min"/>
                    <xsl:sort data-type="number" order="ascending" select="players/@max"/>
                    <xsl:sort data-type="number" order="ascending" select="players/@double-routes-min"/>
                    <xsl:sort data-type="text" order="ascending" select="title"/>
                    <th class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                        <xsl:choose>
                            <xsl:when test="count($games) &gt; 1">
                                <a href="{$normalised-path-to-html}game/{@id}{$ext-html}">
                                    <xsl:apply-templates mode="game.name" select="."/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($min-players, ' - ', $max-players, ' Players')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </th>
                </xsl:for-each>
            </tr>
            <xsl:for-each select="$comparisons//compare[not(@overview = 'false')]">
                <tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                    <td>
                        <xsl:value-of select="label"/>
                    </td>
                    <xsl:apply-templates select="self::compare" mode="games.compare"/>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:template>
    <xsl:template match="comparisons/compare" mode="games.compare">
        <xsl:param name="players" select="0" as="xs:integer" tunnel="yes"/>
        <xsl:param name="games" as="element()*" tunnel="yes"/>
        <xsl:variable name="comparison" select="self::compare"/>
        <xsl:for-each select="$games[not($players &gt; players/@max/number(.))]">
            <xsl:sort data-type="number" order="ascending" select="players/@min"/>
            <xsl:sort data-type="number" order="ascending" select="players/@max"/>
            <xsl:sort data-type="number" order="ascending" select="players/@double-routes-min"/>
            <xsl:sort data-type="text" order="ascending" select="title"/>
            <td class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
                <xsl:apply-templates select="$comparison">
                    <xsl:with-param as="element()" name="game" select="self::game" tunnel="yes"/>
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
    <xsl:template match="compare[@id = 'tickets-total']">
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:value-of select="$total-tickets"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'locations-total']">
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <xsl:value-of select="$total-locations"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-total']">
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:value-of select="$total-routes"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-points-average-max']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:variable as="xs:integer" name="total-max-points" select="     if ($game/tickets/ticket/(@points | */@points)) then      sum($game/tickets/ticket/gw:get-max-ticket-points(.))     else      0"/>
        <xsl:value-of select="format-number($total-max-points div $total-tickets, '0.##')"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-points-average-min']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:variable as="xs:integer" name="total-min-points" select="     if ($game/tickets/ticket/(@points | */@points)) then      sum($game/tickets/ticket/gw:get-min-ticket-points(.))     else      0"/>
        <xsl:value-of select="format-number($total-min-points div $total-tickets, '0.##')"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-value-max']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:for-each select="$game/tickets/ticket">
            <xsl:sort data-type="number" order="descending" select="gw:get-max-ticket-points(self::ticket)"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="gw:get-max-ticket-points(self::ticket)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-value-min']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:for-each select="$game/tickets/ticket">
            <xsl:sort data-type="number" order="ascending" select="gw:get-min-ticket-points(self::ticket)"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="gw:get-min-ticket-points(self::ticket)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="compare[@id = 'routes-shortest']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:for-each select="$game/map/routes/descendant::route">
            <xsl:sort data-type="number" order="ascending" select="@length"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="@length"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="compare[@id = 'routes-longest']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:for-each select="$game/map/routes/descendant::route">
            <xsl:sort data-type="number" order="descending" select="@length"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="@length"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="compare[@id = 'players-min']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:value-of select="$game/players/@min"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'players-max']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:value-of select="$game/players/@max"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-per-location']">
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <xsl:value-of select="format-number(sum($total-tickets div $total-locations), '0.##')"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-per-route-option']">
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:value-of select="format-number(sum($total-tickets div $total-routes), '0.##')"/>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-single-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param name="players" tunnel="yes" as="xs:integer?"/>
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
                <xsl:value-of select="$total-routes"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($game/map/routes/descendant::route[@colour])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-double-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param name="players" tunnel="yes" as="xs:integer?"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">0</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($game/map/routes/descendant::route[count(colour/@ref) = 2]/colour)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-ratio-single-to-double']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:variable as="xs:integer" name="total-single-routes" select="count($game/map/routes/descendant::route[@colour])"/>
        <xsl:variable as="xs:integer" name="total-double-routes" select="count($game/map/routes/descendant::route[count(colour/@ref) = 2]/colour)"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-single-routes, $total-double-routes)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($total-double-routes div $total-single-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-tunnel-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param name="players" tunnel="yes" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
                <xsl:value-of select="count($game/map/routes/descendant::route[@tunnel = 'true'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($game/map/routes/descendant::route[@tunnel = 'true']/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-ferry-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param name="players" tunnel="yes" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
                <xsl:value-of select="count($game/map/routes/descendant::route[@ferry &gt; 0][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($game/map/routes/descendant::route[@ferry &gt; 0]/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-microlight-total']">
        <xsl:param as="element()" name="game" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
                <xsl:value-of select="count($game/map/routes/descendant::route[@microlight = 'true'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count($game/map/routes/descendant::route[@microlight = 'true'][(@colour | colour/@ref)])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-ratio-to-locations']">
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-routes, $total-locations)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($total-locations div $total-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="compare[@id = 'locations-ratio-to-players']">
        <xsl:param as="xs:integer" name="total-locations" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-locations, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-locations, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="compare[@id = 'route-options-ratio-to-players']">
        <xsl:param as="xs:integer" name="total-routes" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-routes, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-routes, '0.#')"/>)</span>
    </xsl:template>
    <xsl:template match="compare[@id = 'tickets-ratio-to-players']">
        <xsl:param as="xs:integer" name="total-tickets" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <span class="ratio">
            <xsl:value-of select="gw:get-ratio($total-tickets, $players)"/>
        </span>
        <xsl:text> </xsl:text>
        <span class="average">(<xsl:value-of select="format-number($players div $total-tickets, '0.#')"/>)</span>
    </xsl:template>
</xsl:stylesheet>