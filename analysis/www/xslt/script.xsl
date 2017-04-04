<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:gw="http://ns.greenwood.thecodeyard.co.uk/xslt/functions" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    exclude-result-prefixes="#all"
    version="2.0" >
    
    <xsl:import href="functions.xsl" />
    
 
	<xsl:template name="generate-network-map" as="element()">
		<xsl:param name="game" select="." as="element()" />
		
		<script type="text/javascript">
			
			<xsl:text>&#10;&#10;</xsl:text>
			
			<!-- Create an array representing the nodes in the network (game map) -->
			<xsl:text>var routesNodeData = [</xsl:text>
			<xsl:apply-templates select="gw:generate-routes-node-data($game)" mode="serialize.javascript" />
			<xsl:text>];</xsl:text>
			
			<xsl:text>&#10;&#10;</xsl:text>
			
			<!-- Create an array representing the edges in the network (game map) -->
			<xsl:text>var routesEdgeData = [</xsl:text>
			<xsl:apply-templates select="gw:generate-routes-edge-data($game)" mode="serialize.javascript" />
			<xsl:text>];</xsl:text>
			
			<xsl:text>&#10;&#10;</xsl:text>
			
			<!-- Populate a vis network visualisation -->
			<xsl:text>var routesNetwork = createNetwork('routes', routesNodeData, routesEdgeData, routesOptions);&#10;</xsl:text>
			
		</script>
	</xsl:template>
    
    
    <xsl:template name="generate-tickets-map" as="element()">
        <xsl:param name="game" as="element()" />
        
        <script type="text/javascript">
            
            <xsl:text>&#10;&#10;</xsl:text>
            
            <!-- Clone routesNodesData, reset mass and size. -->
            <xsl:text>var ticketsNodeData = prepTicketsNodeData(routesNodeData);</xsl:text>
            
            <xsl:text>&#10;&#10;</xsl:text>
            
            <!-- Clone routesEdgesData, delete double edges. -->
            <xsl:text>var simplifiedRoutesEdgeData = prepTicketsEdgeData(routesEdgeData);</xsl:text>
            
            <xsl:text>&#10;&#10;</xsl:text>
            
            <!-- Create an array representing ticket edges (ticket start and end points) -->
            <xsl:text>var ticketsEdgeData = [</xsl:text>
            <xsl:apply-templates select="gw:generate-tickets-edge-data($game)" mode="serialize.javascript" />
            <xsl:text>];</xsl:text>
            
            <xsl:text>&#10;&#10;</xsl:text>
            
            <xsl:text>ticketsEdgeData = simplifiedRoutesEdgeData.concat(ticketsEdgeData);</xsl:text>
            
            <xsl:text>&#10;&#10;</xsl:text>
            
            <!-- Populate a vis network visualisation -->
            <xsl:text>var ticketsNetwork = createNetwork('ticket-distribution', ticketsNodeData, ticketsEdgeData, ticketsOptions);&#10;</xsl:text>
            
        </script>
    </xsl:template>      
  
    <xsl:template match="object" mode="serialize.javascript">
        <xsl:text>{&#10;</xsl:text>
        <xsl:apply-templates mode="#current" />
        <xsl:text>}</xsl:text>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>
    
    <xsl:template match="property" mode="serialize.javascript" priority="10">
        <xsl:value-of select="concat(@label, ': ')" />
        <xsl:next-match />
        <xsl:if test="position() != last()">,</xsl:if>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>
    
    <xsl:template match="property[@data-type = 'xs:string']" mode="serialize.javascript" priority="5">
        <xsl:text>'</xsl:text><xsl:next-match /><xsl:text>'</xsl:text>
    </xsl:template>
    
    <xsl:template match="property" mode="serialize.javascript">
        <xsl:value-of select="." />
    </xsl:template>
    
</xsl:stylesheet>