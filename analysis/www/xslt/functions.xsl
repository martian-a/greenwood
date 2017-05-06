<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <xsl:function name="gw:getColourHex" as="xs:string">
        <xsl:param name="colour-id" as="xs:string" />
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
                <xsl:value-of select="$colour-id" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
	
    
    <!--xsl:function name="gw:square-root" as="xs:double">
		<xsl:param name="number" as="xs:integer" />
		<xsl:value-of select="gw:square-root($number, 1, 1, 20)" />
	</xsl:function>
	
	<xsl:function name="gw:square-root" as="xs:double">
		<xsl:param name="number" as="xs:integer" />
		<xsl:param name="try" as="xs:double" />
		<xsl:param name="iteration" as="xs:integer" />
		<xsl:param name="max-iterations" as="xs:integer" />
		
		<xsl:choose>
			<xsl:when test="$try * $try = $number or $iteration > $max-iterations">
				<xsl:value-of select="$try" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next-try" select="$try - (($try * $try - $number) div (2 * $try))" as="xs:double" />
				<xsl:value-of select="gw:square-root(
					$number, 
					$next-try, 
					$iteration + 1, 
					$max-iterations
					)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<xsl:function name="gw:is-prime-number" as="xs:boolean">
		<xsl:param name="number" as="xs:integer" />
		<xsl:value-of select="gw:is-prime-number($number, 1, gw:square-root($number))" />
	</xsl:function>
	
	<xsl:function name="gw:is-prime-number" as="xs:boolean">
		<xsl:param name="number" as="xs:integer" />
		<xsl:param name="try" as="xs:integer" />
		<xsl:param name="square-root" as="xs:double" />
		
		<xsl:choose>
			<xsl:when test="$number mod $try = 0">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:when test="$try > $square-root">
				<xsl:value-of select="false()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="gw:is-prime-number($number, $try + 1, $square-root)"/>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:function>
	
    <xsl:function name="gw:get-greatest-common-denominator" as="xs:integer?">
        <xsl:param name="x" as="xs:integer"/>
        <xsl:param name="y" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$x < 0">
                <xsl:value-of select="gw:get-greatest-common-denominator(abs($x), $y)"/>
            </xsl:when>
            <xsl:when test="$y < 0">
                <xsl:value-of select="gw:get-greatest-common-denominator($x, abs($y))"/>
            </xsl:when>
            <xsl:when test="sum($x + $y) < 0"></xsl:when>
        	<xsl:when test="($x > 1) and ($y > 1) and gw:is-prime-number($x)">
        		<xsl:value-of select="gw:get-greatest-common-denominator(sum($x - 1), $y)" />
        	</xsl:when>
        	<xsl:when test="($x > 1) and ($y > 1) and gw:is-prime-number($y)">
        		<xsl:value-of select="gw:get-greatest-common-denominator($x, sum($y + 1))" />
        	</xsl:when>
        	<xsl:otherwise>
                <xsl:value-of select="gw:get-greatest-common-denominator($x, $y, $y)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
	
    <xsl:function name="gw:get-greatest-common-denominator" as="xs:integer">
        <xsl:param name="x" as="xs:integer"/>
        <xsl:param name="y" as="xs:integer"/>
        <xsl:param name="g" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$x > 0">
                <xsl:value-of select="gw:get-greatest-common-denominator($y mod $x, $x, $x)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$g"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function -->
    
    
    <xsl:function name="gw:get-ratio" as="xs:string?">
        <xsl:param name="x" as="xs:integer"/>
        <xsl:param name="y" as="xs:integer"/>
        <!-- xsl:variable name="greatest-common-denominator" select="gw:get-greatest-common-denominator($x, $y)" as="xs:integer"/ -->
        <xsl:value-of select="concat(format-number($x div $y, '0.##'), ':1')"/>
    </xsl:function>
    <xsl:function name="gw:get-min-ticket-points" as="xs:integer">
        <xsl:param name="ticket" as="element()"/>
        <xsl:choose>
			<!-- settlement to settlement -->
            <xsl:when test="$ticket/@points">
                <xsl:value-of select="$ticket/@points"/>
            </xsl:when>
			<!-- multi-location -->
            <xsl:otherwise>
				<!-- Find the destination with the highest points -->
                <xsl:for-each select="$ticket/*[@points]">
                    <xsl:sort select="@points" data-type="number" order="ascending"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@points"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="gw:get-max-ticket-points" as="xs:integer">
        <xsl:param name="ticket" as="element()"/>
        <xsl:choose>
			<!-- settlement to settlement -->
            <xsl:when test="$ticket/@points">
                <xsl:value-of select="$ticket/@points"/>
            </xsl:when>
			<!-- multi-location -->
            <xsl:otherwise>
				<!-- Find the destination with the highest points -->
                <xsl:for-each select="$ticket/*[@points]">
                    <xsl:sort select="@points" data-type="number" order="descending"/>
                    <xsl:if test="position() = 1">
                        <xsl:value-of select="@points"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="gw:get-max-ticket-points-for-location" as="xs:integer">
        <xsl:param name="ticket" as="element()"/>
        <xsl:param name="location-id" as="xs:string?"/>
        <xsl:choose>
            <!-- Location is a settlement -->
            <xsl:when test="$ticket/location[@ref = $location-id]">
                <xsl:choose>
                    <!-- settlement to settlement -->
                    <xsl:when test="$ticket/@points">
                        <xsl:value-of select="$ticket/@points"/>
                    </xsl:when>
                    <!-- settlement to region (location is starting point) -->
                    <xsl:when test="$ticket/location[@ref = $location-id][not(@points)]">
                        <!-- Find the destination with the highest points -->
                        <xsl:for-each select="$ticket/*[@points]">
                            <xsl:sort select="@points" data-type="number" order="descending"/>
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="@points"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- settlement to region (location is destination)  -->
                    <xsl:otherwise>
                        <xsl:value-of select="$ticket/location[@ref = $location-id]/@points"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Location is a region -->
            <xsl:when test="$ticket/country[@ref = $location-id]">
                <xsl:variable name="country-id" select="$location-id"/>
                <xsl:choose>
                    <!-- region to region (location is starting point) -->
                    <xsl:when test="$ticket/country[@ref = $country-id][not(@points)]">
                        <!-- Find the destination with the highest points -->
                        <xsl:for-each select="$ticket/*[@points]">
                            <xsl:sort select="@points" data-type="number" order="descending"/>
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="@points"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- region to region (location is destination) -->
                    <xsl:otherwise>
                        <xsl:value-of select="$ticket/country[@ref = $country-id]/@points"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="gw:consolidate-shortest-routes" as="element()*">
        <xsl:param name="shortest-paths" as="element()*" />
        
        <xsl:variable name="start-node" select="$shortest-paths[1]/location[1]" as="element()" />
        <xsl:variable name="end-node" select="$shortest-paths[1]/location[2]" as="element()" />
        <xsl:variable name="start-id" select="$start-node/@ref" as="xs:string" />
        <xsl:variable name="end-id" select="$end-node/@ref" as="xs:string" />
        
        <xsl:variable name="routes" as="element()*">
            <!-- Select only the shortest edge between two adjacent nodes-->
            <xsl:for-each-group select="$shortest-paths/ancestor::map[1]/routes/route" group-by="string-join(location/@ref, '-')">
                <xsl:sort select="@length" data-type="number" order="ascending"/>
                <xsl:sequence select="current-group()[1]" />
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:variable name="start-end-nodes" as="element()*">
            <xsl:for-each select="($start-node | $end-node)">
                <xsl:sort select="@ref" data-type="text" order="ascending" />
                <xsl:sequence select="self::*" />
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:for-each-group select="$shortest-paths/via[@direct = 'true']" group-by="@direct">
            <edge paths="{count(current-group())}" id="{string-join($start-end-nodes/@ref, '-')}">
                <xsl:copy-of select="$routes[location/@ref = $start-id][location/@ref = $end-id]/@length" />
                <xsl:copy-of select="$start-end-nodes" />
            </edge>
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location[1]" group-by="@ref">
            
            <xsl:variable name="start-end-ids" as="xs:string*">
                <xsl:for-each select="$start-id, current-grouping-key()">
                    <xsl:sort select="." data-type="text" order="ascending" />
                    <xsl:sequence select="." />
                </xsl:for-each>
            </xsl:variable>
            
            <edge paths="{count(current-group())}" id="{string-join($start-end-ids, '-')}">
                <xsl:copy-of select="$routes[location/@ref = $start-id][location/@ref = current-grouping-key()]/@length" />
                <location ref="{$start-end-ids[1]}" />
                <location ref="{$start-end-ids[2]}" />
            </edge>
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location" group-by="@ref">
            
            <xsl:variable name="location" select="current-grouping-key()" as="xs:string" />
            
            <xsl:for-each-group select="$shortest-paths/via/location[position() &gt; 1][@ref = $location]" group-by="preceding-sibling::*[1]/@ref">
                
                <xsl:variable name="start-end-ids" as="xs:string*">
                    <xsl:for-each select="$location, current-grouping-key()">
                        <xsl:sort select="." data-type="text" order="ascending" />
                        <xsl:sequence select="." />
                    </xsl:for-each>
                </xsl:variable>
                
                <edge paths="{count(current-group())}" id="{string-join($start-end-ids, '-')}">
                    <xsl:copy-of select="$routes[location/@ref = $location][location/@ref = current-grouping-key()]/@length" />
                    <location ref="{$start-end-ids[1]}" />
                    <location ref="{$start-end-ids[2]}" />
                </edge>
            </xsl:for-each-group>		
            
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location[position() = last()]" group-by="@ref">
            
            <xsl:variable name="start-end-ids" as="xs:string*">
                <xsl:for-each select="$end-id, current-grouping-key()">
                    <xsl:sort select="." data-type="text" order="ascending" />
                    <xsl:sequence select="." />
                </xsl:for-each>
            </xsl:variable>
            
            <edge paths="{count(current-group())}" id="{string-join($start-end-ids, '-')}">
                <xsl:copy-of select="$routes[location/@ref = $end-id][location/@ref = current-grouping-key()]/@length" />
                <location ref="{$start-end-ids[1]}" />
                <location ref="{$start-end-ids[2]}" />
            </edge>
        </xsl:for-each-group>
        
    </xsl:function>
   
    <xsl:function name="gw:get-location-name" as="xs:string?">
        <xsl:param name="location" as="element()" />
        
        <xsl:value-of select="gw:get-location-name($location, false())" />
    </xsl:function>
   
   
   
   
    <xsl:function name="gw:get-location-name" as="xs:string?">
        <xsl:param name="location" as="element()" />
        <xsl:param name="for-js" as="xs:boolean" />
        
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="$location[not(name)]">
                    <xsl:variable name="id" select="$location/(@ref | @id)" as="xs:string" />
                    <xsl:choose>
                        <xsl:when test="$location/ancestor::game[1]/map/locations/descendant::*[@id = $id][not(name)]">
                            <xsl:value-of select="concat($location/ancestor::game[1]/map/locations/descendant::*[@id = $id]/ancestor::*[name][1]/name, ' (', $id, ')')" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$location/ancestor::game[1]/map/locations/descendant::*[name][@id = $id]/name" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$location/name" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       
        
        <xsl:choose>
            
            <xsl:when test="$for-js = true()">
                
                <!-- create an $apos variable to make it easier to refer to -->
                <xsl:variable name="apos" select="codepoints-to-string(39)" />
                
                <xsl:value-of select="replace($name, $apos, '\\''')" />
                
            </xsl:when>
            
            <!-- otherwise... -->
            <xsl:otherwise>
                <xsl:value-of select="$name" />
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:function>
   
   
    <xsl:function name="gw:get-path-start-name" as="xs:string?">
        <xsl:param name="path" as="element()"/>
        <xsl:for-each select="$path/location/gw:get-location-name(.)">
            <xsl:sort select="." data-type="text" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>


    <xsl:function name="gw:get-path-end-name" as="xs:string?">
        <xsl:param name="path" as="element()"/>
        <xsl:for-each select="$path/location/gw:get-location-name(.)">
            <xsl:sort select="." data-type="text" order="ascending"/>
            <xsl:if test="position() = last()">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
	
	<xsl:function name="gw:get-sorted-ticket-locations" as="xs:string*">
		<xsl:param name="ticket" as="element()"/>
		<xsl:choose>
			<xsl:when test="$ticket[count(*[name() = ('location', 'country')]) &gt; 2]">
				<xsl:value-of select="$ticket/*[name() = ('location', 'country')][not(@points)]/gw:get-location-name(.)"/>
				<xsl:text> </xsl:text>
				<xsl:for-each select="$ticket/*[name() = ('location', 'country')][@points]">
					<xsl:sort select="@points" data-type="number" order="ascending"/>
					<xsl:sort select="gw:get-location-name(self::*)" data-type="text" order="ascending"/>
					<xsl:if test="position() = last()">
						<xsl:value-of select="gw:get-location-name(self::*)"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:for-each select="$ticket/*[name() = ('location', 'country')]/gw:get-location-name(.)">
					<xsl:sort select="." data-type="text" order="ascending"/>
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()"><xsl:text> </xsl:text></xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


    <xsl:function name="gw:generate-routes-node-data" as="element()*">
        <xsl:param name="game" as="element()"/>
        
        <xsl:for-each select="$game/map[1]/locations/descendant::location">
            <xsl:variable name="total-tickets" select="count($game/tickets/ticket[location/@ref = current()/@id or country/@ref = current()/ancestor::country[1]/@id])" as="xs:integer" />
            <xsl:variable name="label" select="gw:get-location-name(., true())" as="xs:string?" />
            <object>
                <property label="id" data-type="xs:string"><xsl:value-of select="@id" /></property>
                <property label="label" data-type="xs:string"><xsl:value-of select="normalize-space($label)" /></property>
                <property label="size" data-type="xs:integer"><xsl:value-of select="sum(10 * sum(1 + $total-tickets))" /></property>
                <property label="mass" data-type="xs:integer"><xsl:value-of select="sum(1 + $total-tickets)" /></property>
            <xsl:if test="@x or @y">
                    <property label="fixed" data-type="boolean">true</property>
                    <xsl:if test="@x">
                        <property label="x" data-type="xs:integer">
                            <xsl:value-of select="@x"/>
                        </property>
                    </xsl:if>
                    <xsl:if test="@y">
                        <property label="y" data-type="xs:integer">
                            <xsl:value-of select="@y"/>
                        </property>
                    </xsl:if>
                </xsl:if>
            </object>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="gw:generate-routes-edge-data" as="element()*">
        <xsl:param name="game" as="element()"/>
        
        <xsl:for-each select="$game/map[1]/routes/route/(@colour | colour)">
            <xsl:variable name="route" select="ancestor::route[1]" />
            <xsl:variable name="colour" select="if (self::colour) then @ref else ." />
            <object>
                <property label="from" data-type="xs:string"><xsl:value-of select="$route/location[1]/@ref" /></property>
                <property label="to" data-type="xs:string"><xsl:value-of select="$route/location[2]/@ref" /></property>
                <property label="color" data-type="xs:string"><xsl:value-of select="gw:getColourHex($colour)" /></property>
                <property label="length" data-type="xs:integer"><xsl:value-of select="sum(150 * number($route/@length))" /></property>
            </object>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="gw:generate-tickets-edge-data" as="element()*">
        <xsl:param name="game" as="element()"/>
         
        <xsl:variable name="tickets" select="$game/tickets/ticket" as="element()*" />
        <xsl:variable name="destinations" select="$game/map/locations/descendant::*[@id = $tickets/*[name() = ('location', 'country')]/@ref]" as="element()*" />
        <xsl:variable name="shortest-paths" select="$game/map/shortest-paths/path" as="element()*" />
        
        <xsl:variable name="edges" as="element()*">
            
            <!-- Standard ticket between two locations -->
            <xsl:for-each select="$tickets[not(country)][count(location) = 2]">
                
                <xsl:copy>
                    <xsl:copy-of select="@*" />
                    <xsl:variable name="start" select="location[1]" as="element()" />
                    <xsl:variable name="end" select="location[2]" as="element()" />
                    <!-- Find the data for the shortest paths between the start and end of the ticket -->
                    <xsl:copy-of select="gw:consolidate-shortest-routes($shortest-paths[location/@ref = $start/@ref and location/@ref = $end/@ref])" />    
                </xsl:copy>
            
            </xsl:for-each>
            
            <!-- City-to-country ticket -->
            <xsl:for-each select="$tickets[country][count(location) = 1]">
               
                <xsl:variable name="ticket" select="self::*" as="element()" />
                <xsl:variable name="start" select="location[1]" as="element()" />
                
                <!-- Create a copy of the ticket per country destination -->
                <xsl:for-each select="country">
                    
                    <xsl:variable name="shortest-routes" as="element()*">
                        <xsl:variable name="country-id" select="@ref" as="xs:string" />
                        
                        <!-- 
                            Find the data for the shortest paths between the start city and 
                            each city in the destination country (end of the ticket) 
                        -->
                        <xsl:for-each select="$destinations[@id = $country-id]/descendant::location">
                            <xsl:variable name="end" select="current()" as="element()" />
                            <xsl:copy-of select="gw:consolidate-shortest-routes($shortest-paths[location/@ref = $start/@ref and location/@ref = $end/@id])" />
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <!-- Further consolidate the edges so that there's only one instance of an edge per start-end route -->
                    <xsl:element name="{$ticket/name()}">
                        <xsl:copy-of select="$ticket/@*" />
                        <xsl:copy-of select="@points" />
                        
                        <xsl:for-each-group select="$shortest-routes" group-by="string-join(location/@ref,'-')">
                            <xsl:copy-of select="current-group()[1]" />
                        </xsl:for-each-group>
                    </xsl:element>
                  
                </xsl:for-each>

            </xsl:for-each>
            
            <!-- Country-to-country ticket -->
            <xsl:for-each select="$tickets[count(country[not(@points)]) = 1][country[@points]][not(location)]">
                
                <xsl:variable name="ticket" select="self::*" as="element()" />
                <xsl:variable name="start-country-id" select="country[not(@points)]/@ref" as="xs:string" />
                <xsl:variable name="end-countries" select="country[@points]" as="element()*" />
                
                <!-- Create a copy of the ticket per destination country-->
                <xsl:for-each select="$end-countries">
                    <xsl:variable name="country-id" select="@ref" as="xs:string" />
                    <xsl:variable name="ticket-points" select="@points" as="xs:integer" />
                        
                    <!-- 
                        Find the data for the shortest paths between 
                        each city in the destination country (end of the ticket)
                        and each city in the start country (start of the ticket)
                    -->
                    <xsl:variable name="shortest-routes" as="element()*">
                        <xsl:for-each select="$destinations[@id = $country-id]/descendant::location">
                            <xsl:variable name="end" select="current()" as="element()" />
                            
                            <!-- Loop through all the cities in the start country -->
                            <xsl:for-each select="$destinations[@id = $start-country-id]/descendant::location">
                                <xsl:variable name="start" select="current()" as="element()" />
                                
                                <xsl:copy-of select="gw:consolidate-shortest-routes($shortest-paths[location/@ref = $start/@id and location/@ref = $end/@id])" />    
                                
                            </xsl:for-each>
                            
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <!-- Further consolidate the edges so that there's only one instance of an edge per start-end route -->
                    <xsl:element name="{$ticket/name()}">
                        <xsl:copy-of select="$ticket/@*" />
                        <xsl:copy-of select="@points" />
                        
                        <xsl:for-each-group select="$shortest-routes" group-by="string-join(location/@ref,'-')">
                            <xsl:copy-of select="current-group()[1]" />
                        </xsl:for-each-group>
                    </xsl:element>
                       
                </xsl:for-each>
                    
            </xsl:for-each>
            
        </xsl:variable>        
        
        <xsl:for-each select="$edges/edge">
            <xsl:variable name="edge" select="self::edge" />
            <xsl:variable name="colour" select="if (self::colour) then @ref else ." />
            <xsl:variable name="ticket-points" select="parent::ticket/@points" as="xs:integer" />
            <object>
                <property label="from" data-type="xs:string"><xsl:value-of select="$edge/location[1]/@ref" /></property>
                <property label="to" data-type="xs:string"><xsl:value-of select="$edge/location[2]/@ref" /></property>
                <property label="color" data-type="xs:string">
                    <xsl:choose>
                        <xsl:when test="$ticket-points > 14">#6534ff</xsl:when>
                        <xsl:when test="$ticket-points > 6">#ff66cc</xsl:when>
                        <xsl:otherwise>#66ccff</xsl:otherwise>
                    </xsl:choose>
                </property>
                <property label="length" data-type="xs:integer"><xsl:value-of select="sum(150 * number($edge/@length))" /></property>
            </object>
        </xsl:for-each>
        
    </xsl:function>
    
    
</xsl:stylesheet>