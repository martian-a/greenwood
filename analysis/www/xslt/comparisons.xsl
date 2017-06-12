<xsl:stylesheet xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="#all">
    
	<xsl:variable name="comparisons" as="document-node()">
        <xsl:document>
            <comparisons>
            	<group>
                    <title>Players</title>
                <compare id="players-min" players="false">
						<label>Minimum number of players</label>
					</compare>
					<compare id="players-max" players="false">
						<label>Maximum number of players</label>
					</compare>
				</group>
                <group>
					<title>Starting hand (per player)</title>
					<compare id="start-carriages-total" players="false">
						<label>Total carriages</label>
					</compare>
					<compare id="start-stations-total" players="false">
						<label>Total stations</label>
					</compare>
					<compare id="start-tickets-total" players="false">
						<label>Total tickets dealt (inc. long)</label>
					</compare>
					<compare id="start-tickets-long-total" players="false">
						<label>Total long tickets dealt</label>
					</compare>
					<compare id="start-tickets-must-keep-total" players="false">
						<label>Minimum tickets kept</label>
					</compare>
					<compare id="start-train-cards-total" players="false">
						<label>Total train cards dealt</label>
					</compare>
				</group>
                <group>
            		<title>Map</title>
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
            		<compare id="route-options-value">
            			<label>Total route options value</label>
            		</compare>
            		<compare id="route-options-value-ratio-to-players" overview="false">
            			<label>Ratio of total route options value to players</label>
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
            	</group>
                <group>
                	<title>Tickets</title>
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
                <compare id="tickets-draw-total" players="false">
                		<label>New tickets to draw (max per action)</label>
                	</compare>
                	<compare id="tickets-draw-must-keep" players="false">
                		<label>New tickets must keep (min per action)</label>
                	</compare>
                </group>
                <group>
            		<title>Train Cards</title>
            		<compare id="train-car-draw-max" players="false">
            			<label>Maximum draw (per action, inc. locomotives)</label>
            		</compare>
            		<compare id="locomotive-draw-open-max" players="false">
            			<label>Maximum open draw of locomotives (per action)</label>
            		</compare>
            		<!--
            		<compare id="locomotive-substitute-total" players="false">
            			<label>Total train cards equivalent to a single locomotive (spending)</label>
            		</compare>
            		-->
            	</group>
            	<group>
            		<title>Scoring bonuses</title>
            		<compare id="bonus-total" players="false">
            			<label>Total bonuses</label>
            		</compare>
            		<compare id="bonus-value-max" players="false">
            			<label>Maximum total bonus value</label>
            		</compare>
            	</group>
            </comparisons>
        </xsl:document>
    </xsl:variable>
    
	
	<xsl:template name="games.compare">
        <xsl:param name="games" as="element()*" tunnel="yes"/>
        <xsl:param name="min-players" as="xs:integer?" tunnel="no"/>
        <xsl:param name="max-players" as="xs:integer?" tunnel="no"/>
		<xsl:param name="filter" select="'overview'" as="xs:string" tunnel="yes" />
		<xsl:param name="players" select="0" as="xs:integer" tunnel="no" />
		
        <div class="table">
        	<table>
        		<thead>
        			<tr>
        				<th/>
        				<xsl:for-each select="$games">
        					<xsl:sort data-type="number" order="ascending" select="players/@min"/>
        					<xsl:sort data-type="number" order="ascending" select="players/@max"/>
        					<xsl:sort data-type="number" order="ascending" select="players/@double-routes-min"/>
        					<xsl:sort data-type="text" order="ascending" select="title"/>
        					<xsl:choose>
        						
        						<xsl:when test="count($games) = 1 and $filter = 'players' and $min-players &gt; 0">
        							
        							<!-- Game profile: Comparing more than one player number -->
        							<xsl:for-each select="$min-players to $max-players">
        								<th class="{if (position() mod 2 = 0) then 'even' else 'odd'}"><xsl:value-of select="current()"/> Players</th>
        							</xsl:for-each>
        							
        						</xsl:when>
        						
        						<xsl:otherwise>
        							
        							<th class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
        								<xsl:choose>
        									
        									<!-- Game profile: One game, all players -->
        									<xsl:when test="$min-players &gt; 0">
        										<xsl:value-of select="concat($min-players, ' - ', $max-players, ' Players')"/>
        									</xsl:when>
        									
        									<!-- Home page: Comparing games. -->
        									<xsl:otherwise>
        										<a href="{$normalised-path-to-html}game/{@id}{$ext-html}">
        											<xsl:apply-templates mode="game.name" select="."/>
        										</a>
        									</xsl:otherwise>
        									
        								</xsl:choose>
        							</th>
        							
        						</xsl:otherwise>
        						
        					</xsl:choose>
        					
        				</xsl:for-each>
        			</tr>
        		</thead>

        		<xsl:for-each-group select="$comparisons/descendant::compare[not(@*[name() = $filter] = 'false')]" group-by="if (normalize-space(parent::group/title) != '') then parent::group/title else 'Miscellaneous'">
        			<xsl:sort select="count(parent::group)" data-type="number" order="descending"/>
        			
        			<xsl:variable name="total-columns" as="xs:integer">
        				<xsl:choose>
        					<xsl:when test="count($games) = 1 and $filter = 'players' and $min-players &gt; 0"><xsl:value-of select="($max-players - $min-players) + 2" /></xsl:when>
							<xsl:otherwise><xsl:value-of select="count(games) + 1" /></xsl:otherwise>
        					</xsl:choose>
        			</xsl:variable>
        			
        			<tbody>
        				<tr class="title">
        					<td colspan="{$total-columns}">
        						<xsl:value-of select="current-grouping-key()" />
        					</td>
        				</tr>
        				<xsl:for-each select="current-group()">
        					<xsl:variable name="data-point" select="current()" as="element()" />
        					
        					<tr class="{if (position() mod 2 = 0) then 'even' else 'odd'}">
        						<td><xsl:value-of select="label" /></td>
        						<xsl:choose>
        							
        							<xsl:when test="count($games) = 1 and $filter = 'players' and $min-players &gt; 0">
        								
        								<!-- Game profile: Comparing more than one player number -->
        								<xsl:for-each select="$min-players to $max-players">
        									<xsl:apply-templates select="$data-point" mode="games.compare">
        										<xsl:with-param name="players" select="current()" as="xs:integer" tunnel="yes"/>
        									</xsl:apply-templates>
        								</xsl:for-each>
        								
        							</xsl:when>
        							
        							<xsl:otherwise>
        								
        								<xsl:choose>
        									
        									<!-- Game profile: One game, all players -->
        									<xsl:when test="$min-players &gt; 0">
        										<xsl:apply-templates select="$data-point" mode="games.compare" />
        									</xsl:when>
        									
        									<!-- Home page: Comparing games. -->
        									<xsl:otherwise>
        										<xsl:apply-templates select="$data-point" mode="games.compare">
        											<xsl:with-param name="players" select="$players" as="xs:integer" tunnel="yes"/>
        										</xsl:apply-templates>
        									</xsl:otherwise>
        									
        								</xsl:choose>
        								
        							</xsl:otherwise>
        							
        						</xsl:choose>
        					</tr>
        						
        				</xsl:for-each>
        			</tbody>
        		</xsl:for-each-group>
        		
        	</table>
        </div>
    </xsl:template>
    

    
	
	<xsl:template match="compare[ancestor::comparisons]" mode="games.compare">
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
                            <xsl:when test="$players &gt; 0 and $players &lt; self::game/players/@double-routes-min/number(.)">
                                <xsl:value-of select="count(self::game/map/routes/descendant::route[(@colour | colour/@ref)])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="count(self::game/map/routes/descendant::route/(@colour | colour/@ref))"/>
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
    
	
	<xsl:template match="compare[@id = 'route-options-value']">
		<xsl:param as="element()" name="game" tunnel="yes"/>
		<xsl:param name="players" tunnel="yes" as="xs:integer"/>
		
		<xsl:choose>
			<xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
				<xsl:value-of select="sum(
						  (21 * count($game/map/routes/route[@length = '8']))       
						+ (18 * count($game/map/routes/route[@length = '7']))                
						+ (15 * count($game/map/routes/route[@length = '6']))                
						+ (10 * count($game/map/routes/route[@length = '5']))                
						+ ( 7 * count($game/map/routes/route[@length = '4']))                
						+ ( 4 * count($game/map/routes/route[@length = '3']))                
						+ ( 2 * count($game/map/routes/route[@length = '2']))                
						+       count($game/map/routes/route[@length = '1'])             
					)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="sum(         
						  (21 * count($game/map/routes/route[@length = '8']/(@colour | colour)))       
						+ (18 * count($game/map/routes/route[@length = '7']/(@colour | colour)))                
						+ (15 * count($game/map/routes/route[@length = '6']/(@colour | colour)))                
						+ (10 * count($game/map/routes/route[@length = '5']/(@colour | colour)))                
						+ ( 7 * count($game/map/routes/route[@length = '4']/(@colour | colour)))                
						+ ( 4 * count($game/map/routes/route[@length = '3']/(@colour | colour)))                
						+ ( 2 * count($game/map/routes/route[@length = '2']/(@colour | colour)))                
						+       count($game/map/routes/route[@length = '1']/(@colour | colour))             
					)"/>
			</xsl:otherwise>
		</xsl:choose>
		
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
        <xsl:value-of select="count($game/map/routes/descendant::route[@colour])"/>
    </xsl:template>
    
	
	<xsl:template match="compare[@id = 'route-options-double-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:value-of select="count($game/map/routes/descendant::route[count(color/@ref) = 2]/colour)"/>
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
            	<xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROT'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROT']/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
	
	<xsl:template match="compare[@id = 'route-options-ferry-total']">
        <xsl:param name="game" as="element()" tunnel="yes"/>
        <xsl:param name="players" tunnel="yes" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
                <xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROF'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROF']/(@colour | colour/@ref))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
	
	<xsl:template match="compare[@id = 'route-options-microlight-total']">
        <xsl:param as="element()" name="game" tunnel="yes"/>
        <xsl:param as="xs:integer" name="players" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
            	<xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROM'][(@colour | colour/@ref)])"/>
            </xsl:when>
            <xsl:otherwise>
            	<xsl:value-of select="count($game/map/routes/descendant::route[asset/@ref = 'ROM'][(@colour | colour/@ref)])"/>
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
    
	
	<xsl:template match="compare[@id = 'route-options-value-ratio-to-players']">
		<xsl:param as="element()" name="game" tunnel="yes"/>
		<xsl:param as="xs:integer" name="players" tunnel="yes"/>
		
		<xsl:variable name="route-options-value" as="xs:integer">
			<xsl:choose>
				<xsl:when test="$players &gt; 0 and $players &lt; $game/players/@double-routes-min/number(.)">
					<xsl:value-of select="sum(          
							  (21 * count($game/map/routes/route[@length = '8']))        
							+ (18 * count($game/map/routes/route[@length = '7']))                 
							+ (15 * count($game/map/routes/route[@length = '6']))                 
							+ (10 * count($game/map/routes/route[@length = '5']))                 
							+ ( 7 * count($game/map/routes/route[@length = '4']))                 
							+ ( 4 * count($game/map/routes/route[@length = '3']))                 
							+ ( 2 * count($game/map/routes/route[@length = '2']))                 
							+       count($game/map/routes/route[@length = '1'])              
						)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="sum(
							  (21 * count($game/map/routes/route[@length = '8']/(@colour | colour)))        
							+ (18 * count($game/map/routes/route[@length = '7']/(@colour | colour)))                 
							+ (15 * count($game/map/routes/route[@length = '6']/(@colour | colour)))                
							+ (10 * count($game/map/routes/route[@length = '5']/(@colour | colour)))                
							+ ( 7 * count($game/map/routes/route[@length = '4']/(@colour | colour)))                
							+ ( 4 * count($game/map/routes/route[@length = '3']/(@colour | colour)))                
							+ ( 2 * count($game/map/routes/route[@length = '2']/(@colour | colour)))                
							+       count($game/map/routes/route[@length = '1']/(@colour | colour))              
						)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<span class="ratio">
			<xsl:value-of select="gw:get-ratio($route-options-value, $players)"/>
		</span>
		<xsl:text> </xsl:text>
		<span class="average">(<xsl:value-of select="format-number($players div $route-options-value, '0.#')"/>)</span>
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
	
	
	<xsl:template match="compare[@id = 'start-carriages-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU10']/asset[@ref = 'TOC']" as="element()?"/>
		
		<xsl:value-of select="if ($asset) then $asset/@init else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'start-stations-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU11']/asset[@ref = 'TOS']" as="element()?"/>
		
		<xsl:value-of select="if ($asset) then $asset/@init else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'start-tickets-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU7']/asset[@ref = 'TIC']/asset" as="element()*"/>
		
		<xsl:value-of select="if ($asset) then sum($asset/@init) else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'start-tickets-long-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU7']//asset[@ref = 'TIL']" as="element()?"/>
		
		<xsl:value-of select="if ($asset) then $asset/@init else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'start-tickets-must-keep-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU7']/asset[@ref = 'TIC']" as="element()?"/>
		
		<xsl:value-of select="if ($asset) then $asset/@min else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'start-train-cards-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="asset" select="$game/assets/collection[@id = 'SOU6']/asset[@ref = 'CAR']" as="element()?"/>
		
		<xsl:value-of select="if ($asset) then $asset/@init else 0"/>
	</xsl:template>
	
<xsl:template match="compare[@id = 'bonus-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="action" select="$game/actions/action[@type = 'award'][target/@ref = 'SOU12']" as="element()*"/>
		
		<xsl:value-of select="if ($action) then count($action) else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'bonus-value-max']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="action" select="$game/actions/action[@type = 'award'][target/@ref = 'SOU12']" as="element()*"/>
		
		<xsl:value-of select="if ($action) then sum($action/target[@ref = 'SOU12']/@max) else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'tickets-draw-total']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="action" select="$game/actions/action[@type = 'draw'][source/@ref = 'SOU5']" as="element()*"/>
		
		<xsl:value-of select="if ($action) then sum($action/source/@max) else 0"/>
	</xsl:template>
	
	<xsl:template match="compare[@id = 'tickets-draw-must-keep']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="action" select="$game/actions/action[@type = 'draw'][source/@ref = 'SOU5']" as="element()*"/>
		
		<xsl:value-of select="if ($action) then $action/target[@ref = 'SOU6']/@min else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare[@id = 'train-car-draw-max']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="face-up" as="xs:integer?">
			<xsl:for-each select="$game/actions/action[target/@ref = 'SOU6']/source[@ref = 'SOU1'][@max]">
				<xsl:sort select="@max" data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="@max"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="face-down" as="xs:integer?">
			<xsl:for-each select="$game/actions/action[target/@ref = 'SOU6']/source[@ref = 'SOU2'][@max]">
				<xsl:sort select="@max" data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="@max"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="if ($face-up &gt; $face-down) then $face-up else $face-down"/>
	</xsl:template>
	
	<xsl:template match="compare[@id = 'locomotive-draw-open-max']">
		<xsl:param name="game" as="element()" tunnel="yes"/>
		<xsl:variable name="face-up" as="xs:integer?">
			<xsl:for-each select="$game/actions/action[target/@ref = 'SOU6']/source[@ref = 'SOU1'][not(asset)][@max] | $game/actions/action[target/@ref = 'SOU6']/source[@ref = 'SOU1']/asset[@ref = 'TRW'][@max]">
				<xsl:sort select="@max" data-type="number" order="descending"/>
				<xsl:if test="position() = 1">
					<xsl:value-of select="@max"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="if ($face-up &gt; 0) then $face-up else 0"/>
	</xsl:template>
	
	
	<xsl:template match="compare"/>

	
</xsl:stylesheet>