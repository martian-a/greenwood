<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:d="http://ns.kaikoda.com/documentation/xml"
    exclude-result-prefixes="xs inkscape svg d"
    version="2.0">
    
    <d:doc scope="stylesheet">
        <d:desc>
            <d:p>Parses data from an SVG file (typically cards.svg) and generates ticket XML formatted per game.dtd</d:p>
        </d:desc>
        <d:note>
            <d:ul>
                <d:ingress>Assumptions:</d:ingress>
                <d:li>The input file contains a layer called "Routes" which contains a single sub-layer per ticket.</d:li>
                <d:li>The name of each ticket layer follows the format "%d-d% (%p)". Where %d is the name of a location on the map and %p is the total points the ticket is worth.</d:li>
                <d:li>No other layer that's a descendant of "Routes" has a name that contains a hypen.</d:li>
                <d:li>The existing data file contains a list of all the locations referenced in the tickets, formatted per game.dtd</d:li>
            </d:ul>
        </d:note>
        <d:note>
            <d:p>See extract_and_merge_map.xsl for parsing location and route data from an SVG file.</d:p>
        </d:note>
    </d:doc>
    
    
    <d:doc>
        <d:desc>Configure properties of the output result.</d:desc>
    </d:doc>
    <xsl:output encoding="UTF-8"
         indent="yes"
         media-type="text/xml"
         method="xml" />
    
    <d:doc>
        <d:desc>
            <d:p>Path to an existing file with which the tickets data is to be merged.</d:p>
        </d:desc>
        <d:note>
            <d:p>The existing file is expected to conform to game.dtd.</d:p>
            <d:p>The contents of the existing file will be preserved, except for existing tickets data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>
    <xsl:param name="path-to-existing-data" select="'game.xml'" as="xs:string" />
    
    
    <d:doc>
        <d:desc>The existing data.</d:desc>
    </d:doc>
    <xsl:variable name="existing-data" select="document($path-to-existing-data)" as="document-node()" />
    
    
    <d:doc>
        <d:desc>Match the root of the SVG document, parse it for ticket data ($tickets) and output a copy of the existing data file supplied with the new ticket data merged into it.</d:desc>
        <d:note>
            <d:p>The contents of the existing file will be preserved, except for existing tickets data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>  
    <xsl:template match="/">
        <xsl:apply-templates select="$existing-data" mode="copy">
            <xsl:with-param name="tickets" as="document-node()" tunnel="yes">
                <xsl:apply-templates select="svg:svg/svg:g[@inkscape:label='Routes']" />
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Process a "Routes" layer to generate tickets XML (formatted per game.dtd)</d:desc>
        <d:note>
            <d:p>A ticket element will be created for each ticket layer.</d:p>
            <d:p>The existing data file is used for looking-up the ID of each location referenced on the ticket.</d:p>
        </d:note>
    </d:doc>
    <xsl:template match="svg:g[@inkscape:label='Routes']">
        <xsl:variable name="locations" select="$existing-data/game/map/locations/descendant::*[@id][name]" as="element()*" />
        <xsl:document>
            <tickets>
                <xsl:for-each select="descendant::svg:g[@inkscape:groupmode='layer'][@inkscape:label/contains(., '-')]">
                    <xsl:sort select="@inkscape:label" data-type="text" order="ascending" />
                    <xsl:variable name="points" select="normalize-space(substring-before(substring-after(@inkscape:label, '('), ')'))" as="xs:string" />
                    <ticket points="{$points}">
                        <xsl:for-each select="tokenize(substring-before(@inkscape:label, '('), '-')">
                            <xsl:sort select="." data-type="text" order="ascending" />
                            <xsl:for-each select="$locations[name = normalize-space(current())]">
                                <location ref="{@id}" />
                            </xsl:for-each>
                        </xsl:for-each>
                        <xsl:for-each select="descendant::svg:g[@inkscape:label='Text']/svg:text">
                            <note><xsl:value-of select="." /></note>
                        </xsl:for-each>
                    </ticket>
                </xsl:for-each>
            </tickets>
        </xsl:document>
     </xsl:template>
    
    
    
    <d:doc>
        <d:desc>Make a deep copy of the existing data and replace any existing tickets data with the new tickets XML.</d:desc>
    </d:doc>
    <xsl:template match="map" mode="copy" priority="10">
        <xsl:param name="tickets" as="document-node()" tunnel="yes" />
        <xsl:next-match />
        <xsl:copy-of select="$tickets" />
    </xsl:template>
    
    
    <d:doc>
        <d:desc>
            <d:ul>
                <d:ingress>Delete content in the existing data file that's not wanted in the result document:</d:ingress>
                <d:li>tickets (existing)</d:li>
                <d:li>route attributes set to default values (no need to express explicitly)</d:li>
            </d:ul>
        </d:desc>
    </d:doc>
    <xsl:template match="tickets | route/@*[name() = ('tunnel', 'microlight')][. = 'false'] | route/@ferry[. = '0']" mode="copy" />
    
    
    <d:doc>
        <d:desc>Make a deep copy of an element.</d:desc>
    </d:doc>
    <xsl:template match="*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current" />
            <xsl:apply-templates mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Copy an attribute, comment or processing instruction.</d:desc>
    </d:doc>
    <xsl:template match="@* | comment() | processing-instruction()" mode="copy">
        <xsl:copy />
    </xsl:template>
    
</xsl:stylesheet>