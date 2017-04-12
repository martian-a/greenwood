<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	exclude-result-prefixes="#all" 
	version="2.0">
	
	<xsl:import href="game.xsl" />
	<xsl:import href="location.xsl" />
    <xsl:import href="script.xsl"/>
    
	<xsl:param name="path-to-js" select="'../../../js/'" as="xs:string"/>
    <xsl:param name="path-to-css" select="'../../../style/'" as="xs:string"/>
    <xsl:param name="path-to-xml" select="'../../xml'" as="xs:string"/>
    <xsl:param name="path-to-html" select="'../../html'" as="xs:string"/>
    <xsl:param name="static" select="'false'" as="xs:string"/>
    
	<xsl:output method="html" encoding="utf-8" media-type="text/html" indent="yes" omit-xml-declaration="yes" version="5"/>
    
	<xsl:variable name="normalised-path-to-js">
        <xsl:variable name="directory-separators" select="translate($path-to-js, '\', '/')"/>
        <xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')"/>
    </xsl:variable>
    
	<xsl:variable name="normalised-path-to-css">
        <xsl:variable name="directory-separators" select="translate($path-to-css, '\', '/')"/>
        <xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')"/>
    </xsl:variable>
    
	<xsl:variable name="normalised-path-to-xml" select="translate($path-to-xml, '\', '/')"/>
    <xsl:variable name="normalised-path-to-html" select="translate($path-to-html, '\', '/')"/>
    <xsl:variable name="ext-xml" select="if (xs:boolean($static)) then '.xml' else ''" as="xs:string?"/>
    <xsl:variable name="ext-html" select="if (xs:boolean($static)) then '.html' else ''" as="xs:string?"/>
    <xsl:variable name="index" select="if (xs:boolean($static)) then 'index' else ''" as="xs:string?"/>
    
	
	<xsl:template match="/">
        <html>
            <head>
                <xsl:apply-templates mode="html.header"/>
                <link type="text/css" href="{$normalised-path-to-css}global.css" rel="stylesheet"/>
            </head>
            <body>
            	<xsl:apply-templates mode="nav.site"/>
				<div class="content">
					<xsl:apply-templates mode="html.body"/>
				</div>
            </body>
        </html>
    </xsl:template>
    
	<xsl:template match="game" mode="game.name">
        <xsl:value-of select="title"/>
    </xsl:template>
    
	<xsl:template match="game | games | location | locations" mode="nav.site">
        <div class="header">
            <h2>TTR Analysis</h2>
            <ul class="nav-site">
                <li>
                    <a href="{$normalised-path-to-html}/game/{$index}{$ext-html}">Games</a>
                </li>
                <li>
                    <a href="{$normalised-path-to-html}/location/{$index}{$ext-html}">Locations</a>
                </li>
                <xsl:apply-templates select="self::game | self::location" mode="nav.site.xml"/>
            </ul>
        </div>
    </xsl:template>
    
	<xsl:template match="game" mode="nav.site.xml" priority="10">
        <xsl:next-match>
            <xsl:with-param name="href" select="concat($normalised-path-to-xml, '/game/', @id, $ext-xml)" as="xs:string"/>
        </xsl:next-match>
    </xsl:template>
    
	<xsl:template match="location" mode="nav.site.xml" priority="10">
        <xsl:next-match>
            <xsl:with-param name="href" select="concat($normalised-path-to-xml, '/location/', games/game[1]/@id, '-', @id, $ext-xml)" as="xs:string"/>
        </xsl:next-match>
    </xsl:template>
    
	<xsl:template match="game | location" mode="nav.site.xml">
        <xsl:param name="href" as="xs:string"/>
        <li>
            <a href="{$href}">XML</a>
        </li>
    </xsl:template>
    
	<xsl:template match="game | location" mode="nav.page" priority="100">
        <div class="contents">
            <h2>Contents</h2>
            <ul>
                <xsl:next-match/>
            </ul>
        </div>
    </xsl:template>
	
</xsl:stylesheet>