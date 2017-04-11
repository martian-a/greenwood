<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	exclude-result-prefixes="#all"
	version="2.0">
	
	<xsl:import href="script.xsl" />
	<xsl:import href="functions.xsl" />
	
	<xsl:param name="path-to-js" select="'../../../js/'" as="xs:string" />
	<xsl:param name="path-to-css" select="'../../../style/'" as="xs:string" />
	<xsl:param name="path-to-xml" select="'../../xml'" as="xs:string" />
	<xsl:param name="path-to-html" select="'../../html'" as="xs:string" />
	<xsl:param name="static" select="'false'" as="xs:string" />
	

	<xsl:output 
		method="html"
		encoding="utf-8"
		media-type="text/html"
		indent="yes" 
		omit-xml-declaration="yes"
		version="5" />
	
	
	<xsl:variable name="normalised-path-to-js">
		<xsl:variable name="directory-separators" select="translate($path-to-js, '\', '/')" />
		<xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')" />
	</xsl:variable>
	
	<xsl:variable name="normalised-path-to-css">
		<xsl:variable name="directory-separators" select="translate($path-to-css, '\', '/')" />
		<xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')" />
	</xsl:variable>
	
	<xsl:variable name="normalised-path-to-xml" select="translate($path-to-xml, '\', '/')" />
	
	<xsl:variable name="normalised-path-to-html" select="translate($path-to-html, '\', '/')" />
	
	<xsl:variable name="ext-xml" select="if (xs:boolean($static)) then '.xml' else ''" as="xs:string?" />
	<xsl:variable name="ext-html" select="if (xs:boolean($static)) then '.html' else ''" as="xs:string?" />
	<xsl:variable name="index" select="if (xs:boolean($static)) then 'index' else ''" as="xs:string?" />
	
	<xsl:template match="/">
		<html>
			<head>
				<xsl:apply-templates mode="html.header" />
				<link type="text/css" href="{$normalised-path-to-css}global.css" rel="stylesheet" />
			</head>
			<body>
				<xsl:apply-templates mode="html.body" />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="game" mode="game.name">
		<xsl:value-of select="title" />
	</xsl:template>
	
	<xsl:template name="site-navigation">
		<p> <a href="{$normalised-path-to-html}/game/{$index}{$ext-html}">Games</a> | <a href="{$normalised-path-to-xml}/game/{@id}{$ext-xml}">XML</a> </p>
	</xsl:template>
	
</xsl:stylesheet>