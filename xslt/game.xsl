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
    <xsl:template match="games" mode="html.header">
        <title>Games</title>
    </xsl:template>
    <xsl:template match="game" mode="html.header">
        <title>
            <xsl:value-of select="title"/>
        </title>
        <style type="text/css">
            div.locations ul {
                -webkit-column-count: 3; /* Chrome, Safari, Opera */
                -moz-column-count: 3; /* Firefox */
                column-count: 3;
                -webkit-column-gap: 5em; /* Chrome, Safari, Opera */
                -moz-column-gap: 5em; /* Firefox */
                column-gap: 5em;
            }
        </style>
    </xsl:template>
    <xsl:template match="games" mode="html.body">
        <p>
            <a href="../xml/game.xml">XML</a>
        </p>
        <h1>Games</h1>
        <ul>
            <xsl:for-each select="//game">
                <li>
                    <a href="game.html?id={@id}">
                        <xsl:apply-templates select="." mode="game.name"/>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <xsl:template match="game" mode="html.body">
        <p>
            <a href="game.html">Games</a> | <a href="../xml/game.xml?id={@id}">XML</a>
        </p>
        <h1>
            <xsl:value-of select="title"/>
        </h1>
        <xsl:apply-templates select="map/locations"/>
        <xsl:apply-templates select="map/routes">
            <xsl:with-param name="colour" select="map/colours/colour" as="element()*" tunnel="yes"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="locations">
        <div class="locations">
            <h2>Locations</h2>
            <p>Total: <xsl:value-of select="count(descendant::location)"/>
            </p>
            <ul>
                <xsl:for-each select="descendant::location">
                    <li>
                        <a href="location.html?id={@id}">
                            <xsl:apply-templates select="." mode="location.name"/>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </div>
    </xsl:template>
    <xsl:template match="routes">
        <xsl:param name="colour" as="element()*" tunnel="yes"/>
        <xsl:variable name="routes" select="." as="element()"/>
        <h2>Routes</h2>
        <h3>Options</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
        <h3>Double Routes</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[count(colour) &gt; 1]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[count(colour) &gt; 1]/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[count(colour) &gt; 1]/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[count(colour) &gt; 1]/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
        <h3>Tunnels</h3>
        <table>
            <tr>
                <th>Length</th>
                <xsl:for-each select="$colour">
                    <th>
                        <xsl:value-of select="name"/>
                    </th>
                </xsl:for-each>
                <th>Total</th>
            </tr>
            <xsl:for-each-group select="route" group-by="@length">
                <xsl:sort select="current-grouping-key()" order="descending" data-type="number"/>
                <tr>
                    <td>
                        <xsl:value-of select="current-grouping-key()"/>
                    </td>
                    <xsl:for-each select="$colour">
                        <xsl:variable name="colour-id" select="@id"/>
                        <td>
                            <xsl:value-of select="count(current-group()[@tunnel = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                        </td>
                    </xsl:for-each>
                    <td>
                        <xsl:value-of select="count(current-group()[@tunnel = 'true']/(@colour | colour/@ref))"/>
                    </td>
                </tr>
            </xsl:for-each-group>
            <tr>
                <td>Total</td>
                <xsl:for-each select="$colour">
                    <xsl:variable name="colour-id" select="@id"/>
                    <td>
                        <xsl:value-of select="count($routes/route[@tunnel = 'true']/(@colour[. = $colour-id] | colour[@ref = $colour-id]))"/>
                    </td>
                </xsl:for-each>
                <td>
                    <xsl:value-of select="count($routes/route[@tunnel = 'true']/(@colour | colour/@ref))"/>
                </td>
            </tr>
        </table>
    </xsl:template>
    <xsl:template match="game" mode="game.name">
        <xsl:value-of select="title"/>
    </xsl:template>
    <xsl:template match="location[name]" mode="location.name">
        <xsl:value-of select="name"/>
    </xsl:template>
    <xsl:template match="location[not(name)]" mode="location.name">
        <xsl:value-of select="concat(ancestor::country[1]/name, ' (', @id, ')')"/>
    </xsl:template>
</xsl:stylesheet>