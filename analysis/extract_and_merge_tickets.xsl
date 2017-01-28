<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
    xmlns:svg="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs inkscape svg"
    version="2.0">
    
    <xsl:output encoding="UTF-8"
         indent="yes"
         media-type="text/xml"
         method="xml" />
    
    <xsl:param name="path-to-map" select="'../data/west_dorset.xml'" as="xs:string" />
    <xsl:variable name="map" select="document($path-to-map)" as="document-node()" />
    
    <xsl:template match="/">
        <xsl:apply-templates select="$map" mode="copy">
            <xsl:with-param name="tickets" as="document-node()" tunnel="yes">
                <xsl:apply-templates select="svg:svg/svg:g[@inkscape:label='Routes']" />
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="svg:g">
        <xsl:variable name="locations" select="$map/game/map/locations/descendant::*[@id][name]" as="element()*" />
        <xsl:document>
            <tickets>
                <xsl:for-each select="descendant::svg:g[@inkscape:groupmode='layer'][@inkscape:label/contains(., '-')]">
                    <xsl:sort select="@inkscape:label" data-type="text" order="ascending" />
                    <xsl:variable name="points" select="substring-before(substring-after(@inkscape:label, '('), ')')" as="xs:string" />
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
    
    <xsl:template match="map" mode="copy" priority="10">
        <xsl:param name="tickets" as="document-node()" tunnel="yes" />
        <xsl:next-match />
        <xsl:copy-of select="$tickets" />
    </xsl:template>
    
    
    <xsl:template match="tickets | route/@*[name() = ('tunnel', 'microlight')][. = 'false'] | route/@ferry[. = '0']" mode="copy" />
    
    
    <xsl:template match="*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current" />
            <xsl:apply-templates mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@* | comment() | processing-instruction()" mode="copy">
        <xsl:copy />
    </xsl:template>
    
</xsl:stylesheet>