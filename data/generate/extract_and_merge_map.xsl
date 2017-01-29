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
            <d:p>Parses data from an SVG file (typically board.svg) and generates location and route XML formatted per game.dtd</d:p>
            <d:p>The result is merged in with default data copied from a template file (typically game.xml).</d:p>
        </d:desc>
        <d:note>
            <d:ul>
                <d:ingress>Assumptions:</d:ingress>
                <d:li>The SVG file contains a layer called "Edges (named)" which contains a single sub-layer per route between locations.</d:li>
                <d:li>The name of each ticket layer follows the format "%d-d%". Where %d is the name of a location on the map.</d:li>
                <d:li>No other layer that's a descendant of "Routes" has a name that contains a hypen.</d:li>
                <d:li>There is a default data file that contains a map element containing colour data, formatted per game.dtd</d:li>
            </d:ul>
        </d:note>
        <d:note>
            <d:p>See extract_and_merge_tickets.xsl for parsing ticket data from an SVG file.</d:p>
        </d:note>
    </d:doc>
    
    
    <d:doc>
        <d:desc>Configure properties of the output result.</d:desc>
    </d:doc>
    <xsl:output encoding="UTF-8"
         indent="yes"
         media-type="text/xml"
         method="xml" />
    
    
    <d:doc>An ID to be assigned to this game.</d:doc>
    <xsl:param name="game-id" select="''" required="no" as="xs:string" />
    
    
    <d:doc>The name of the custom TTR game.</d:doc>
    <xsl:param name="game-title" select="''" required="no" as="xs:string" />
    
    
    <d:doc>
        <d:desc>
            <d:p>Path to an existing file that contains default data to be included in the output result.</d:p>
        </d:desc>
        <d:note>
            <d:p>The existing file is expected to conform to game.dtd.</d:p>
            <d:p>The contents of the existing file will be preserved, except for existing tickets data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>
    <xsl:param name="path-to-existing-data" select="'../game.xml'" as="xs:string" />
    
    
    <d:doc>
        <d:desc>The existing data.</d:desc>
    </d:doc>
    <xsl:variable name="existing-data" select="document($path-to-existing-data)" as="document-node()" />
    
    
    
    <d:doc>
        <d:desc>Match the root of the SVG document, parse it for map data and output a copy of the existing data file supplied with the new map data merged into it.</d:desc>
        <d:note>
            <d:p>The contents of the existing file will be preserved, except for existing map data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>  
    <xsl:template match="/">
        <xsl:apply-templates select="$existing-data" mode="copy">
            <xsl:with-param name="svg" select="svg:svg" as="element()" tunnel="yes" />
        </xsl:apply-templates>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>
            <d:ul>
                <d:ingress>Make a deep copy of the existing game data and:</d:ingress>
                <d:li>replace any existing map data with the new map XML</d:li>
                <d:li>replace the game ID ($game-id), if supplied</d:li>
                <d:li>insert or replace the game title ($game-title), if supplied</d:li>
            </d:ul>    
        </d:desc>
    </d:doc>
    <xsl:template match="game" mode="copy">
        <xsl:copy>
            <xsl:attribute name="id">
                <xsl:choose>
                    <xsl:when test="$game-id != ''"><xsl:value-of select="$game-id" /></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@id" /></xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*[name() != 'id']" mode="copy" />
                <xsl:choose>
                    <xsl:when test="$game-title != ''">
                        <title>
                            <xsl:apply-templates select="title/@*" mode="#current" />
                            <xsl:value-of select="$game-title" />
                        </title>
                    </xsl:when>
                    <xsl:otherwise><xsl:apply-templates select="title" mode="copy" /></xsl:otherwise>
                </xsl:choose>
            <xsl:apply-templates select="node()[not(self::title)]" mode="copy" />
        </xsl:copy>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Make a deep copy of the existing map data and replace any existing map data with the new map XML.</d:desc>
    </d:doc>
    <xsl:template match="map" mode="copy">
        <xsl:param name="svg" as="element()" tunnel="yes" /> 
            
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current" />
            <xsl:apply-templates select="$svg/descendant::svg:g[@inkscape:label='Edges (named)'][1]" mode="map" />
            <xsl:apply-templates select="node()[not(self::*[name() = ('locations', 'routes')])]" mode="#current" />
        </xsl:copy>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Process the "Edges (named)" layer to generate locations and routes XML (formatted per game.dtd)</d:desc>
        <d:note>
            <d:p>A route element will be created for each child layer containing a hyphen.</d:p>
            <d:p>A location element will be created for each distinct location name referenced in the route layers.</d:p>
        </d:note>
    </d:doc>
    <xsl:template match="svg:g[@inkscape:label='Edges (named)']" mode="map">
        <xsl:variable name="routes" select="svg:g/@inkscape:label[contains(., '-')]" as="attribute()*" />
        <xsl:variable name="locations" as="document-node()">
           <xsl:apply-templates select="self::*" mode="locations">
               <xsl:with-param name="routes" select="$routes" as="attribute()*" />
           </xsl:apply-templates>
        </xsl:variable>
        
        <xsl:copy-of select="$locations" />          
        <xsl:apply-templates select="self::*" mode="routes">
            <xsl:with-param name="routes" select="$routes" as="attribute()*" />
            <xsl:with-param name="locations" select="$locations" as="document-node()" />
        </xsl:apply-templates>
     </xsl:template>
    
    
    <d:doc>
        <d:desc>Process the "Edges (named)" layer to generate locations XML (formatted per game.dtd)</d:desc>
        <d:note>
            <d:p>A location element will be created for each distinct location name referenced in the route layers.</d:p>
            <d:p>Each location will be given an ID.</d:p>
        </d:note>
    </d:doc>
    <xsl:template match="svg:g" mode="locations">
        <xsl:param name="routes" as="attribute()*" />
        
        <xsl:variable name="names" as="element()">
            <locations>
                <xsl:for-each select="distinct-values($routes/tokenize(., '-'))">
                    <xsl:sort select="." data-type="text" order="ascending" />
                    <location>
                        <name normalised="{translate(upper-case(.), ' ''', '')}"><xsl:value-of select="normalize-space(.)" /></name>
                    </location>
                </xsl:for-each>
            </locations>
        </xsl:variable>
        
        <xsl:document>
         <locations>
             <xsl:for-each select="$names/location">
                 <xsl:variable name="abbreviation" as="xs:string">
                     <xsl:variable name="initial" select="substring(name/@normalised, 1, 3)" as="xs:string" />
                     <xsl:variable name="prior-duplicates" select="count(preceding::location[substring(name/@normalised, 1, 3) = $initial])" as="xs:integer" /> 
                     <xsl:value-of select="concat($initial, if ($prior-duplicates > 0) then xs:integer($prior-duplicates + 1) else '')" />                
                 </xsl:variable>
                 
                 <xsl:copy>
                     <xsl:attribute name="id" select="$abbreviation" />
                     <xsl:apply-templates select="@*" mode="copy" />
                     <xsl:apply-templates mode="copy" />
                 </xsl:copy>
             </xsl:for-each>
         </locations>
        </xsl:document>
    </xsl:template>
    
    
    
    <d:doc>
        <d:desc>Process the "Edges (named)" layer to generate routes XML (formatted per game.dtd)</d:desc>
        <d:note>
            <d:p>A route element will be created for each corresponding route layer.</d:p>
            <d:p>The newly-generated locations XML ($locations) is used for looking-up the ID of each location referenced in the route.</d:p>
        </d:note>
    </d:doc>
    <xsl:template match="svg:g" mode="routes">
        <xsl:param name="routes" as="attribute()*" />
        <xsl:param name="locations" as="document-node()" />
        
        <routes>
            <xsl:for-each select="$routes">
                <xsl:sort select="." data-type="text" order="ascending" />
                <route>
                    <xsl:for-each select="tokenize(., '-')">
                        <xsl:sort select="normalize-space(.)" data-type="text" order="ascending" />
                        <xsl:for-each select="$locations/descendant::location[name = normalize-space(current())]">
                            <location ref="{@id}" />
                        </xsl:for-each>
                    </xsl:for-each>
                </route>
            </xsl:for-each>
        </routes>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>
            <d:ul>
                <d:ingress>Delete content that's not wanted in the result document:</d:ingress>
                <d:li>normalised location name</d:li>
            </d:ul>
        </d:desc>
    </d:doc>
    <xsl:template match="location/name/@normalised" mode="copy" />
    
    
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
    <xsl:template match="@* | comment() | processing-instruction() | text()" mode="copy">
        <xsl:copy />
    </xsl:template>
    
</xsl:stylesheet>