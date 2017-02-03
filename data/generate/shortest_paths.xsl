<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" media-type="text/xml" />
	
	<xsl:param name="filename" select="tokenize(translate(document-uri(/), '\', '/'), '/')[last()]" as="xs:string" />
    
    <xsl:template match="/">
    	<xsl:variable name="network" select="/game/map/network" as="element()?" />
      	
      	<xsl:result-document href="../paths/{$filename}">
	    	<game id="{/game/@id}">
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
									<xsl:with-param name="current" select="$initial" as="element()" />
									<xsl:with-param name="target" select="current()" as="element()" />
									<xsl:with-param name="all" select="$all" as="element()*" />
									<xsl:with-param name="network" select="$network" as="element()" tunnel="yes" />
								</xsl:call-template>
							</xsl:for-each>
			    			
						</xsl:for-each>
		    		</shortest-paths>
	    		</map>
	    	</game>
      	</xsl:result-document>
    	
    </xsl:template>
	
	<xsl:template name="distance-check">
		<xsl:param name="initial" as="element()" tunnel="yes" />
		<xsl:param name="current" as="element()" />
		<xsl:param name="target" as="element()" />
		<xsl:param name="all" as="element()*" />
		<xsl:param name="network" as="element()" tunnel="yes" />
		
		<xsl:variable name="unvisited" select="$all[@visited = false()]" as="element()*" />
		
		<xsl:variable name="tentative" as="element()*">
			<xsl:for-each select="$network/edges/edge[node/@ref = $current/@id]/node[@ref != $current/@id][@ref = $unvisited/@id]">
				<xsl:sort select="@length" data-type="number" order="ascending" />
				<xsl:copy>
					<xsl:attribute name="id" select="@ref" />
					<xsl:attribute name="distance" select="sum(number($all[@id = $current/@id]/@distance) + number(parent::edge/@length))" />
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
					<xsl:when test="$tentative[@id = current()/@id][@distance &lt; current()/@distance]">
						<!-- 
							It's possible for there to be two edges between a pair of nodes, 
							for example, between Weymouth and Fortuneswell on the West Dorset map:
							- ferry (6)
							- normal (4)
						-->
						<xsl:for-each select="$tentative[@id = current()/@id]">
							<xsl:sort select="@distance" data-type="number" order="ascending" />
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
		
		<xsl:choose>
			<xsl:when test="$updated-distances[@id = $target/@id][@visited = true()]">
				<path distance="{$updated-distances[@id = $target/@id]/@distance}">
					<location ref="{$initial/@id}" />
					<location ref="{$target/@id}" />
				</path>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="distance-check">
					<xsl:with-param name="current" as="element()">
						<xsl:for-each select="$updated-distances[@visited = false()][@distance != '∞']">
							<xsl:sort select="@distance" data-type="number" order="ascending" />
							<xsl:if test="position() = 1">
								<xsl:copy-of select="self::*" />
							</xsl:if>
						</xsl:for-each>
					</xsl:with-param>
					<xsl:with-param name="target" select="$target" as="element()" />
					<xsl:with-param name="all" select="$updated-distances" as="element()*" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


</xsl:stylesheet>