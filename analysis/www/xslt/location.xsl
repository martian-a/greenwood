<xsl:stylesheet 
	xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="#all" 
	version="2.0">
	
	<xsl:template match="locations" mode="html.header">
        <title>Locations</title>
    </xsl:template>
    
	<xsl:template match="location" mode="html.header">
        <title>
            <xsl:value-of select="name"/>
        </title>
    </xsl:template>
    
	<xsl:template match="locations" mode="html.body">
        <h1>Locations</h1>
        <ul>
            <xsl:for-each select="//location">
                <xsl:sort select="if (name) then name else ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending"/>
                <xsl:variable name="game-id" select="games/game[1]/@id" as="xs:string"/>
                <li>
                    <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                        <xsl:value-of select="gw:get-location-name(.)"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    
	<xsl:template match="location" mode="html.body">
        <xsl:variable name="game-id" select="games/game[1]/@id" as="xs:string"/>
        <h1><xsl:value-of select="name"/></h1>
		<xsl:apply-templates select="games"/>
        <xsl:apply-templates select="self::*" mode="nav.page"/>
        <xsl:apply-templates select="connections"/>
        <xsl:apply-templates select="shortest-paths"/>
    </xsl:template>
    
	<xsl:template match="location" mode="nav.page">
		<li><a href="#connections">Connections</a></li>
		<li><a href="#shortest-paths">Shortest Paths</a></li>
		<!-- 
			TODO: Add list of tickets that start/end at this location.
			<li><a href="#tickets">Tickets</a></li>
		-->
	</xsl:template>
    
	<xsl:template match="games">
		<div id="games">
			<p class="game">
				<span class="label">Game</span>
				<span class="delimiter">:</span><xsl:text> </xsl:text>
				<xsl:for-each select="game">
					<a href="{$normalised-path-to-html}/game/{@id}{$ext-html}">
						<xsl:value-of select="title"/>
					</a>
					<xsl:if test="position() != last()">
						<span class="delimiter">,</span><xsl:text> </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</p>
		</div>
    </xsl:template>
    
	<xsl:template match="connections">
        <div id="connections">
        	<h2>Connections</h2>
        	<p class="summary">All locations adjacent to <xsl:value-of select="/location/name" />.</p>
        	<table>
        		<tr>
        			<th>Location</th>
        			<th>Length</th>
        			<th>Double</th>
        			<th>Colours</th>
        			<th>Type</th>
        			<th>Locomotives Required (Min)</th>
        		</tr>
        		<xsl:apply-templates select="location" mode="connections"/>
        	</table>
        </div>
    </xsl:template>
    
	<xsl:template match="location" mode="connections">
        <xsl:variable name="game-id" select="/location/games/game[1]/@id" as="xs:string"/>
        <tr>
            <td>
                <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                    <xsl:value-of select="gw:get-location-name(.)"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="@length"/>
            </td>
            <td>
                <xsl:value-of select="count(colour) &gt; 1"/>
            </td>
            <td>
                <xsl:value-of select="string-join(colour, ', ')"/>
            </td>
            <td>
                <xsl:choose>
                    <xsl:when test="@tunnel = 'true'">Tunnel</xsl:when>
                    <xsl:when test="@microlight = 'true'">Microlight</xsl:when>
                    <xsl:when test="@ferry &gt; 0">Ferry</xsl:when>
                    <xsl:otherwise>Normal</xsl:otherwise>
                </xsl:choose>
            </td>
            <td>
                <xsl:value-of select="if (@ferry &gt; 0) then @ferry else 0"/>
            </td>
        </tr>
    </xsl:template>
    
	<xsl:template match="location/shortest-paths">
        <div id="shortest-paths">
        	<h2>Shortest Paths</h2>
        	<p class="summary">The minimum number of carriages (distance) required to claim a route between <xsl:value-of select="/location/name" /> and each other reachable location on the map.</p>
        	<table>
        		<tr>
        			<th>Location</th>
        			<th>Distance</th>
        		</tr>
        		<xsl:apply-templates select="location" mode="shortest-path"/>
        	</table>
        </div>
    </xsl:template>
    
	<xsl:template match="location" mode="shortest-path">
        <xsl:variable name="game-id" select="/location/games/game[1]/@id" as="xs:string"/>
        <tr>
            <td>
                <a href="{$normalised-path-to-html}/location/{$game-id}-{@id}{$ext-html}">
                    <xsl:value-of select="gw:get-location-name(.)"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="@distance"/>
            </td>
        </tr>
    </xsl:template>
	
</xsl:stylesheet>