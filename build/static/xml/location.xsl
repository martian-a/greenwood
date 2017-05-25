<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	
	<xsl:param name="location-id" required="yes" />
	
	<xsl:key name="location" match="*[name() = ('location', 'country')][ancestor::locations/parent::map]" use="@id" /> 
	<xsl:key name="colour" match="/game/map/colours/colour" use="@id" />
	
	
	<xsl:template match="/">
		<xsl:variable name="location" select="key('location', $location-id)" as="element()*" />
		
		<xsl:choose>
			<xsl:when test="count($location) = 1">
				<xsl:apply-templates select="$location" />
			</xsl:when>
			<xsl:when test="count($location) > 1">
				<xsl:message terminate="yes"><xsl:text>More than one location found.</xsl:text></xsl:message>
				<xsl:apply-templates select="/" mode="error">
					<xsl:with-param name="location" select="$location" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message terminate="yes"><xsl:text>No location found.</xsl:text></xsl:message>
				<xsl:apply-templates select="/" mode="error">
					<xsl:with-param name="location" select="$location" />
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="location | country">
		<xsl:param name="with-connections" select="true()" as="xs:boolean" />
		<xsl:param name="with-shortest-paths" select="true()" as="xs:boolean" />
		<xsl:param name="with-sub-locations" select="true()" as="xs:boolean" />
		<xsl:variable name="id" select="@id" as="xs:string" />
		
		<location id="{$id}">
			<xsl:apply-templates select="self::*" mode="name" />
			<games>
				<xsl:apply-templates select="ancestor::game[1]" mode="games" />
			</games>
			<xsl:apply-templates select="ancestor::map[1][$with-connections = true()]/routes[route/location/@ref = $id]"  mode="connections" />
			<xsl:apply-templates select="ancestor::map[1][$with-shortest-paths = true()]/shortest-paths[path/location/@ref = $id]"  mode="shortest-paths" />	
			<xsl:apply-templates select="self::*[$with-sub-locations = true()][descendant::*/@id]"  mode="sub-locations" />
		</location>
		
		
	</xsl:template>
	
	<xsl:template match="routes" mode="connections">
		<connections>
			<xsl:apply-templates select="route[location/@ref = $location-id]" mode="connections" />
		</connections>
	</xsl:template>
	
	<xsl:template match="shortest-paths" mode="shortest-paths">
		<shortest-paths>
			<xsl:apply-templates select="path[location/@ref = $location-id]"  mode="shortest-path" />
		</shortest-paths>
	</xsl:template>
	
	<xsl:template match="*[name() = ('country', 'location')]" mode="sub-locations">
		<sub-locations>
			<xsl:apply-templates select="descendant::*[@id]">
				<xsl:with-param name="with-connections" select="false()" as="xs:boolean" />
				<xsl:with-param name="with-shortest-paths" select="false()" as="xs:boolean" />
				<xsl:with-param name="with-sub-locations" select="false()" as="xs:boolean" />
			</xsl:apply-templates>
		</sub-locations>
	</xsl:template>
	
	<xsl:template match="*[name() = ('location', 'country')]" mode="name">
		<xsl:choose>
			<xsl:when test="name">
				<xsl:copy-of select="name" />
			</xsl:when>
			<xsl:otherwise>
				<name><xsl:value-of select="concat(ancestor::country[1]/name, ' (', @id, ')')" /></name>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template match="game" mode="games">
		<game>
			<xsl:copy-of select="@id" />
			<xsl:copy-of select="title" />
		</game>
	</xsl:template>
	
	<xsl:template match="route" mode="connections">
		<xsl:variable name="route" select="self::*" as="element()" />
		<xsl:for-each select="location[@ref != $location-id]">
			<xsl:variable name="terminus-id" select="@ref" as="xs:string" />
			<xsl:variable name="terminus" select="key('location', $terminus-id)" as="element()" />
			<location 
				id="{xs:string($terminus/@id)}" 
				length="{xs:integer($route/@length)}" 
				tunnel="{xs:boolean($route/@tunnel)}" 
				ferry="{if ($route/@ferry > 0) then $route/@ferry else 0}" 
				microlight="{xs:boolean($route/@microlight)}">
				<xsl:apply-templates select="$terminus" mode="name" />
				<xsl:apply-templates select="$route/(@colour | colour/@ref)" mode="colour" />
			</location>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="route/@length" mode="connections">
		<xsl:copy />
	</xsl:template>
	
	<xsl:template match="route/@*[name() = ('tunnel', 'microlight')]" mode="connections">
		<xsl:attribute name="{name()}" select="xs:boolean(.)" />
	</xsl:template>
	
	<xsl:template match="route/@ferry" mode="connections">
		<xsl:attribute name="{name()}" select="xs:boolean(.)" />
	</xsl:template>
	
	<xsl:template match="@colour | colour/@ref" mode="colour">
		<xsl:variable name="colour-id" select="xs:string(.)" as="xs:string" />
		
		<colour><xsl:value-of select="key('colour', $colour-id)/name" /></colour>
	</xsl:template>
	
	<xsl:template match="path" mode="shortest-path">
		<xsl:variable name="terminus-id" select="location[@ref != $location-id]/@ref" as="xs:string" />
		<xsl:variable name="terminus" select="key('location', $terminus-id)" as="element()" />
		
		<location id="{$terminus-id}" distance="{@distance}">
			<xsl:apply-templates select="$terminus" mode="name" />
		</location>
	</xsl:template>
	

	
	
	<xsl:template match="/" mode="error">
		<xsl:param name="location" />
		
		<error>
			<location-id><xsl:value-of select="$location-id" /></location-id>
			<matches>
				<xsl:copy-of select="$location" />
			</matches>
		</error>
	</xsl:template>
	
</xsl:stylesheet>