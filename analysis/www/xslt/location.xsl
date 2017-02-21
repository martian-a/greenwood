<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
	
	<xsl:param name="path-to-css" select="'../style/'" />
	<xsl:param name="path-to-js" select="'../js/'" />
	<xsl:param name="path-to-xml" select="'../xml/'" />
	
	<xsl:variable name="normalised-path-to-js">
		<xsl:variable name="directory-separators" select="translate($path-to-js, '\', '/')" />
		<xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')" />
	</xsl:variable>
	
	<xsl:variable name="normalised-path-to-css">
		<xsl:variable name="directory-separators" select="translate($path-to-css, '\', '/')" />
		<xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')" />
	</xsl:variable>
	
	<xsl:variable name="normalised-path-to-xml">
		<xsl:variable name="directory-separators" select="translate($path-to-xml, '\', '/')" />
		<xsl:value-of select="concat($directory-separators, if (ends-with($directory-separators, '/')) then '' else '/')" />
	</xsl:variable>
	
    <xsl:template match="/">
        <html>
            <head>
                <xsl:apply-templates mode="html.header"/>
            </head>
            <body>
                <xsl:apply-templates mode="html.body"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="locations" mode="html.header">
        <title>Locations</title>
    </xsl:template>
    <xsl:template match="location" mode="html.header">
        <title>
            <xsl:value-of select="name"/>
        </title>
    </xsl:template>
    <xsl:template match="locations" mode="html.body">
        <p>
            <a href="{$normalised-path-to-xml}/location/index.xml">XML</a>
        </p>
        <h1>Locations</h1>
        <ul>
            <xsl:for-each select="//location">
            	<xsl:sort select="if (name) then name else ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending" />
                <xsl:variable name="game-id" select="games/game[1]/@id" as="xs:string"/>
                <li>
                    <a href="{$game-id}-{@id}.html">
                        <xsl:apply-templates select="." mode="location.name"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="location" mode="html.body">
        <xsl:variable name="game-id" select="games/game[1]/@id" as="xs:string"/>
        <p>
            <a href="index.html">Locations</a> | <a href="{$normalised-path-to-xml}/location/{$game-id}-{@id}.xml">XML</a>
        </p>
        <h1>
            <xsl:value-of select="name"/>
        </h1>
        <xsl:apply-templates select="games"/>
        <xsl:apply-templates select="connections"/>
    <xsl:apply-templates select="shortest-paths"/>
    </xsl:template>
    <xsl:template match="games">
        <h2>Games</h2>
        <ul>
            <xsl:for-each select="game">
                <li>
                    <a href="../game/{@id}.html">
                        <xsl:value-of select="title"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="connections">
        <h2>Connections</h2>
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
    </xsl:template>
    <xsl:template match="location" mode="connections">
        <xsl:variable name="game-id" select="/location/games/game[1]/@id" as="xs:string"/>
        <tr>
            <td>
                <a href="{$game-id}-{@id}.html">
                    <xsl:apply-templates select="." mode="location.name"/>
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
            	<xsl:value-of select="if (@ferry > 0) then @ferry else 0" />
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="shortest-paths">
        <h2>Shortest Path</h2>
        <table>
            <tr>
                <th>Location</th>
                <th>Distance</th>
            </tr>
            <xsl:apply-templates select="location" mode="shortest-path"/>
        </table>
    </xsl:template>
    <xsl:template match="location" mode="shortest-path">
        <xsl:variable name="game-id" select="/location/games/game[1]/@id" as="xs:string"/>
        <tr>
            <td>
                <a href="{$game-id}-{@id}.html">
                    <xsl:apply-templates select="." mode="location.name"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="@distance"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="location[name]" mode="location.name">
        <xsl:value-of select="name"/>
    </xsl:template>
    <xsl:template match="location[not(name)]" mode="location.name">
        <xsl:value-of select="concat(ancestor::country[1]/name, ' (', @id, ')')"/>
    </xsl:template>
</xsl:stylesheet>