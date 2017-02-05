<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" />
    
	<xsl:param name="filename" select="tokenize(translate(document-uri(/), '\', '/'), '/')[last()]" as="xs:string" />
	
    <xsl:template match="/">
        <game id="{game/@id}">
        	<map>
        		<network>
		            <xsl:apply-templates select="game/map/locations" />
		            <xsl:apply-templates select="game/map/routes" />
        		</network>
        	</map>
        </game>
    </xsl:template>
    
    <xsl:template match="locations">
        <nodes>
            <xsl:apply-templates select="descendant::location" />
        </nodes>
    </xsl:template>
    
    <xsl:template match="location[ancestor::locations]">
        <node id="{@id}">
            <xsl:copy-of select="name" />
        </node>
    </xsl:template>
    
    <xsl:template match="location[parent::route]">
        <node ref="{@ref}" />
    </xsl:template>
    
    <xsl:template match="routes">
        <edges>
            <xsl:apply-templates select="route" />
        </edges>
    </xsl:template>
    
    <xsl:template match="route">
    	<xsl:variable name="total-prior-alternative-routes" select="count(preceding-sibling::route[location/@ref = current()/location[1]/@ref][location/@ref = current()/location[2]/@ref])" as="xs:integer" />
    	<xsl:variable name="id" select="concat(location[1]/@ref, '-', location[2]/@ref, if ($total-prior-alternative-routes &gt; 0) then concat('-', sum($total-prior-alternative-routes + 1)) else '')" as="xs:string" />
    	
        <edge id="{$id}" length="{@length}">
            <xsl:apply-templates select="location" />
        </edge>
    </xsl:template>
    
</xsl:stylesheet>