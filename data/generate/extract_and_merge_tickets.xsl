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
                <d:li>The SVG file contains a layer called "Routes" which contains a single sub-layer per ticket.</d:li>
                <d:li>The name of each ticket layer follows the format "%d-d% (%p)". Where %d is the name of a location on the map and %p is the total points the ticket is worth.</d:li>
                <d:li>No other layer that's a descendant of "Routes" has a name that contains a hypen.</d:li>
                <d:li>The existing data includes a list of all the locations referenced in the tickets, formatted per game.dtd</d:li>
            </d:ul>
        </d:note>
        <d:note>
            <d:p>See extract_and_merge_map.xsl for parsing location and route data from an SVG file.</d:p>
        </d:note>
    	<d:note>
    		<d:p>This stylesheet is designed for use within a pipeline (extract_data_from_svg.xpl).</d:p>
    		<d:p>To facilitate use of two source documents (SVG, existing data) where one of these is the result of a previous step, 
    			<em>without saving the result of that previous step to the filesystem</em> 
    			the pipeline temporarily merges the two sources into a single document prior to supplying it to this stylesheet.</d:p>
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
			<d:p>The path to a file containing existing data with which the tickets data is to be merged.</d:p>
		</d:desc>
		<d:note>
			<d:p>This is not required if this stylesheet is being executed within the extract_data_from_svg pipeline.</d:p>
		</d:note>
	</d:doc>
	<xsl:param name="path-to-existing-data-document" as="xs:string?" required="no" />
    
    <d:doc>
        <d:desc>
            <d:p>Existing data with which the tickets data is to be merged.</d:p>
        </d:desc>
        <d:note>
            <d:p>The existing data is expected to conform to game.dtd.</d:p>
            <d:p>The existing data will be preserved, except for existing tickets data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>
	<xsl:variable name="existing-data" select="if ($path-to-existing-data-document != '') then document($path-to-existing-data-document)/game else /descendant-or-self::game[1]" as="element()" />
    
    
    <d:doc>
        <d:desc>Match the root of the SVG document, parse it for ticket data ($tickets) and output a copy of the existing data file supplied with the new ticket data merged into it.</d:desc>
        <d:note>
            <d:p>The existing data will be preserved, except for existing tickets data, which will be replaced with the result of this transform.</d:p>
        </d:note>
    </d:doc>  
    <xsl:template match="/">
    	<xsl:variable name="svg" select="/descendant-or-self::svg:svg[1]" as="element()" />
    	
        <xsl:apply-templates select="$existing-data" mode="copy">
            <xsl:with-param name="tickets" as="document-node()" tunnel="yes">
                <xsl:apply-templates select="$svg/svg:g[@inkscape:label='Routes']" />
            </xsl:with-param>
        </xsl:apply-templates>
    </xsl:template>
    
    
    <d:doc>
        <d:desc>Process a "Routes" layer to generate tickets XML (formatted per game.dtd)</d:desc>
        <d:note>
            <d:p>A ticket element will be created for each ticket layer.</d:p>
            <d:p>The existing data is used for looking-up the ID of each location referenced on the ticket.</d:p>
        </d:note>
    </d:doc>
    <xsl:template match="svg:g[@inkscape:label='Routes']">
        <xsl:variable name="locations" select="$existing-data/map/locations/descendant::*[@id][name]" as="element()*" />
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
                <d:ingress>Delete content in the existing data that's not wanted in the result document:</d:ingress>
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