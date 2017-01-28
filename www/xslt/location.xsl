<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
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
            <a href="../xml/location.xml">XML</a>
        </p>
        <h1>Locations</h1>
        <ul>
            <xsl:for-each select="//location">
            	<xsl:sort select="if (name) then name else ancestor::country[1]/concat(name, ' (', @id, ')')" data-type="text" order="ascending" />
                <li>
                    <a href="location.html?id={@id}">
                        <xsl:apply-templates select="." mode="location.name"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="location" mode="html.body">
        <p>
            <a href="location.html">Locations</a> | <a href="../xml/location.xml?id={@id}">XML</a>
        </p>
        <h1>
            <xsl:value-of select="name"/>
        </h1>
        <xsl:apply-templates select="games"/>
        <xsl:apply-templates select="connections"/>
    </xsl:template>
    <xsl:template match="games">
        <h2>Games</h2>
        <ul>
            <xsl:for-each select="game">
                <li>
                    <a href="game.html?id={@id}">
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
                <th>Tunnel</th>
                <th>Ferries</th>
            </tr>
            <xsl:apply-templates select="location" mode="connections"/>
        </table>
    </xsl:template>
    <xsl:template match="location" mode="connections">
        <tr>
            <td>
                <a href="location.html?id={@id}">
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
                <xsl:value-of select="@tunnel"/>
            </td>
            <td>
            	<xsl:value-of select="if (@ferry > 0) then @ferry else 0" />
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