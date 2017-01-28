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
    
    <xsl:template match="/">
        <game id="WDR">
            <title>West Dorset</title>
            <map>
                <xsl:apply-templates select="svg:svg/svg:g[@inkscape:label='Edges (named)']" />
            </map>
        </game>
    </xsl:template>
    
    <xsl:template match="svg:g">
        <xsl:variable name="edges" select="svg:g/@inkscape:label" />
        <xsl:variable name="nodes" as="element()*">
            <xsl:variable name="name" as="document-node()">
                <xsl:document>
                    <locations>
                     <xsl:for-each select="distinct-values($edges/tokenize(., '-'))">
                         <xsl:sort select="." data-type="text" order="ascending" />
                         <location><xsl:value-of select="." /></location>
                     </xsl:for-each>
                    </locations>
                </xsl:document>
            </xsl:variable>
            <xsl:for-each select="$name/locations/location">
                <xsl:variable name="abbreviation" as="xs:string">
                    <xsl:variable name="initial" select="upper-case(substring(., 1, 3))" as="xs:string" />
                    <xsl:variable name="prior-duplicates" select="count(preceding-sibling::location[upper-case(substring(., 1, 3)) = $initial])" as="xs:integer" /> 
                    <xsl:value-of select="concat($initial, if ($prior-duplicates > 0) then xs:integer($prior-duplicates + 1) else '')" />                
                </xsl:variable>
                <location>
                    <xsl:attribute name="abbreviation" select="$abbreviation" />
                    <name><xsl:value-of select="." /></name>
                </location>
            </xsl:for-each>
        </xsl:variable>
        <locations>
            <country id="WDO">
                <name>West Dorset</name>
                <xsl:copy-of select="$nodes" />  
            </country>
        </locations>
        <routes>
            <xsl:for-each select="$edges">
                <xsl:sort select="." data-type="text" order="ascending" />
                <route>
                    <xsl:for-each select="tokenize(., '-')">
                        <xsl:sort select="." data-type="text" order="ascending" />
                        <xsl:for-each select="$nodes[name = current()]">
                            <location ref="{@abbreviation}" />
                        </xsl:for-each>
                    </xsl:for-each>
                </route>
            </xsl:for-each>
        </routes>
     </xsl:template>
    
</xsl:stylesheet>