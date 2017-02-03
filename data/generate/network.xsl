<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" />
    
	<xsl:param name="filename" select="tokenize(translate(document-uri(/), '\', '/'), '/')[last()]" as="xs:string" />
	
    <xsl:template match="/">
    	<xsl:result-document href="networks/{$filename}">
	        <game id="{game/@id}">
	        	<map>
	        		<network>
			            <xsl:apply-templates select="game/map/locations" />
			            <xsl:apply-templates select="game/map/routes" />
	        		</network>
	        	</map>
	        </game>
    	</xsl:result-document>
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
        <edge id="{position()}" length="{@length}">
            <xsl:apply-templates select="location" />
        </edge>
    </xsl:template>
    
</xsl:stylesheet>