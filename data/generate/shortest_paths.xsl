<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" media-type="text/xml" />
	
	<xsl:param name="filename" select="tokenize(translate(document-uri(/), '\', '/'), '/')[last()]" as="xs:string" />
	<xsl:param name="debug" select="false()" />
    
    <xsl:template match="/game/map/network[nodes/node][edges/edge]">
    	<xsl:variable name="network" select="self::network" as="element()?" />

    	<game>
    		<xsl:copy-of select="/game/@id" />
    		<map>
	    		<shortest-paths>
		    		<xsl:for-each select="$network/nodes/node">
						<xsl:variable name="initial" select="self::node" as="element()" />
						
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
		    			
						<xsl:for-each select="$initial/following-sibling::node">
							<xsl:call-template name="distance-check">
								<xsl:with-param name="initial" select="$initial" as="element()" tunnel="yes" />
								<xsl:with-param name="current" select="$all[@id = $initial/@id]" as="element()" />
								<xsl:with-param name="target" select="current()" as="element()" />
								<xsl:with-param name="all" select="$all" as="element()*" />
								<xsl:with-param name="network" select="$network" as="element()" tunnel="yes" />
							</xsl:call-template>
						</xsl:for-each>
		    			
					</xsl:for-each>
	    		</shortest-paths>
    		</map>
    	</game>
    	
    </xsl:template>
	
	<xsl:template name="distance-check">
		<xsl:param name="initial" as="element()" tunnel="yes" />
		<xsl:param name="current" as="element()" />
		<xsl:param name="target" as="element()" />
		<xsl:param name="all" as="element()*" />
		<xsl:param name="network" as="element()" tunnel="yes" />
		
		<xsl:variable name="unvisited" select="$all[@visited = false()]" as="element()*" />
		<xsl:variable name="unvisited-neighbours-of-current" select="$unvisited[@id != $current/@id][@id = $network/edges/edge[node/@ref = $current/@id]/node/@ref]" as="element()*" />
		
		<xsl:variable name="tentative" as="element()*">
			<xsl:for-each select="$network/edges/edge[node/@ref = $current/@id]/node[@ref = $unvisited-neighbours-of-current/@id]">
				<xsl:copy>
					<xsl:attribute name="id" select="@ref" />
					<xsl:attribute name="distance" select="if ($current/@distance = '∞') then parent::edge/@length else sum($current/@distance + parent::edge/@length)" />
					<xsl:attribute name="visited" select="false()" />
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
	
		<xsl:variable name="updated-distances" as="element()*">
			<xsl:for-each select="$all">
				<xsl:choose>
					<xsl:when test="@id = $current/@id">
						<xsl:copy>
							<xsl:copy-of select="@id, @distance" />
							<xsl:attribute name="visited" select="true()" />
						</xsl:copy>
					</xsl:when>
					<xsl:when test="self::*[
							(@distance = '∞' and @id = $tentative/@id ) or 
							(@distance != '∞' and @id = $tentative[number(@distance) &lt; number(current()/@distance)]/@id)
						]">
						<!-- 
							It's possible for there to be two edges between a pair of nodes, 
							for example, between Weymouth and Fortuneswell on the West Dorset map:
							- ferry (6)
							- normal (4)
						-->
						<xsl:for-each select="$tentative[@id = current()/@id]">
							<xsl:sort select="@distance" data-type="number" order="ascending" />
							<xsl:sort select="@id" data-type="text" order="ascending" />
							<xsl:if test="position() = 1">
								<xsl:copy-of select="self::*" />
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="self::*" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		
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
		
		<xsl:if test="$debug = true()">
			<xsl:variable name="filename" select="concat('temp/', $initial/@id, '/', $target/@id, '/', $current/@id, '.xml')" />
			<xsl:result-document href="{$filename}">
				<distance-check>
					<initial><xsl:copy-of select="$initial" /></initial>
					<current><xsl:copy-of select="$current" /></current>
					<target><xsl:copy-of select="$target" /></target>
					<all><xsl:copy-of select="$all" /></all>
					<unvisited><xsl:copy-of select="$unvisited" /></unvisited>
					<unvisited-neighbours-of-current><xsl:copy-of select="$unvisited-neighbours-of-current" /></unvisited-neighbours-of-current>
					<tentative><xsl:copy-of select="$tentative" /></tentative>
					<updated-distances><xsl:copy-of select="$updated-distances" /></updated-distances>
					<queue><xsl:copy-of select="$queue" /></queue>
				</distance-check>
			</xsl:result-document>	
		</xsl:if>
		
		<xsl:choose>
			<xsl:when test="count($queue) &lt; 1">
				<path distance="{$updated-distances[@id = $target/@id]/@distance}">
					<location ref="{$initial/@id}" />
					<location ref="{$target/@id}" />
				</path>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="distance-check">
					<xsl:with-param name="current" select="$queue[1]" as="element()" />					
					<xsl:with-param name="target" select="$target" as="element()" />
					<xsl:with-param name="all" select="$updated-distances" as="element()*" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>