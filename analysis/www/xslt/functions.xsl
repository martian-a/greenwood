<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    
    
    <xsl:template match="path" mode="path.name">
        <xsl:apply-templates select="*[1]" mode="location.name" />
        <xsl:text> to </xsl:text>
        <xsl:apply-templates select="*[2]" mode="location.name" />
    </xsl:template>
    <xsl:function name="gw:getColourHex" as="xs:string">
        <xsl:param name="colour-id" as="xs:string" />
        <xsl:choose>
            <xsl:when test="$colour-id = 'RED'">#FF0000</xsl:when>
            <xsl:when test="$colour-id = 'ORA'">#FF8C00</xsl:when>
            <xsl:when test="$colour-id = 'YEL'">#FFD700</xsl:when>
            <xsl:when test="$colour-id = 'GRN'">#32CD32</xsl:when>
            <xsl:when test="$colour-id = 'BLU'">#4169E1</xsl:when>
            <xsl:when test="$colour-id = 'VIO'">#9370DB</xsl:when>
            <xsl:when test="$colour-id = 'BLA'">#000000</xsl:when>
            <xsl:when test="$colour-id = 'WHI'">#FFFFFF</xsl:when>
            <xsl:when test="$colour-id = 'GRY'">#C0C0C0</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$colour-id" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    
    <xsl:function name="gw:getMaxPoints" as="xs:integer">
        <xsl:param name="ticket" as="element()" />
        <xsl:param name="location-id" as="xs:string?" />
        
        <xsl:choose>
            <!-- Location is a settlement -->
            <xsl:when test="$ticket/location[@ref = $location-id]">
                <xsl:choose>
                    <!-- settlement to settlement -->
                    <xsl:when test="$ticket/@points">
                        <xsl:value-of select="$ticket/@points" />
                    </xsl:when>
                    <!-- settlement to region (location is starting point) -->
                    <xsl:when test="$ticket/location[@ref = $location-id][not(@points)]">
                        <!-- Find the destination with the highest points -->
                        <xsl:for-each select="$ticket/*[@points]">
                            <xsl:sort select="@points" data-type="number" order="descending" />
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="@points" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- settlement to region (location is destination)  -->
                    <xsl:otherwise>
                        <xsl:value-of select="$ticket/location[@ref = $location-id]/@points" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <!-- Location is a region -->
            <xsl:when test="$ticket/country[@ref = $location-id]">
                <xsl:variable name="country-id" select="$location-id" />
                <xsl:choose>
                    <!-- region to region (location is starting point) -->
                    <xsl:when test="$ticket/country[@ref = $country-id][not(@points)]">
                        <!-- Find the destination with the highest points -->
                        <xsl:for-each select="$ticket/*[@points]">
                            <xsl:sort select="@points" data-type="number" order="descending" />
                            <xsl:if test="position() = 1">
                                <xsl:value-of select="@points" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <!-- region to region (location is destination) -->
                    <xsl:otherwise>
                        <xsl:value-of select="$ticket/country[@ref = $country-id]/@points" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <xsl:function name="gw:consolidate-shortest-routes" as="element()*">
        <xsl:param name="shortest-paths" as="element()*" />
        
        
        <xsl:variable name="start-node" select="$shortest-paths[1]/location[1]/@ref" as="xs:string" />
        <xsl:variable name="end-node" select="$shortest-paths[1]/location[2]/@ref" as="xs:string" />
        <xsl:variable name="routes" as="element()*">
            <!-- Select only the shortest edge between two adjacent nodes-->
            <xsl:for-each-group select="$shortest-paths/ancestor::map[1]/routes/route" group-by="string-join(location/@ref, '-')">
                <xsl:sort select="@length" data-type="number" order="ascending"/>
                <xsl:sequence select="current-group()[1]" />
            </xsl:for-each-group>
        </xsl:variable>
        
        <xsl:for-each-group select="$shortest-paths/via[@direct = 'true']" group-by="@direct">
            <edge paths="{count(current-group())}" id="{$start-node}-{$end-node}">
                <xsl:copy-of select="$routes[location/@ref = $start-node][location/@ref = $end-node]/@length" />
                <location ref="{$start-node}" />
                <location ref="{$end-node}" />
            </edge>
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location[1]" group-by="@ref">
            <edge paths="{count(current-group())}" id="{$start-node}-{current-grouping-key()}">
                <xsl:copy-of select="$routes[location/@ref = $start-node][location/@ref = current-grouping-key()]/@length" />
                <location ref="{$start-node}" />
                <location ref="{current-grouping-key()}" />
            </edge>
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location" group-by="@ref">
            
            <xsl:variable name="location" select="current-grouping-key()" as="xs:string" />
            
            <xsl:for-each-group select="$shortest-paths/via/location[position() &gt; 1][@ref = $location]" group-by="preceding-sibling::*[1]/@ref">
                <edge paths="{count(current-group())}" id="{$location}-{current-grouping-key()}">
                    <xsl:copy-of select="$routes[location/@ref = $location][location/@ref = current-grouping-key()]/@length" />
                    <location ref="{$location}" />
                    <location ref="{current-grouping-key()}" />
                </edge>
            </xsl:for-each-group>		
            
        </xsl:for-each-group>
        
        <xsl:for-each-group select="$shortest-paths/via/location[position() = last()]" group-by="@ref">
            <edge paths="{count(current-group())}" id="{current-grouping-key()}-{$end-node}">
                <xsl:copy-of select="$routes[location/@ref = $end-node][location/@ref = current-grouping-key()]/@length" />
                <location ref="{current-grouping-key()}" />
                <location ref="{$end-node}" />
            </edge>
        </xsl:for-each-group>
        
    </xsl:function>
    
    
</xsl:stylesheet>