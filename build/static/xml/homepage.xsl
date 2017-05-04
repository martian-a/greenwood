<xsl:stylesheet 
	xmlns:xi="http://www.w3.org/2001/XInclude"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	version="2.0">
		
		<!-- c:directory xmlns:c="http://www.w3.org/ns/xproc-step"
			name="game"
			xml:base="file:///home/sheila/repositories/git/greenwood/dist/www/xml//game/">
			<c:file name="GUSA.xml"/>
			<c:file name="GINDIA.xml"/>
			<c:file name="SWI.xml"/>
			<c:file name="WDR.xml"/>
		</c:directory -->
	
		
	<xsl:template match="/*">
		<games>
			<xsl:copy-of select="@xml:base" />
			<xsl:apply-templates select="*" /> 			
		</games>		
	</xsl:template>	
	
	<xsl:template match="*[local-name() = 'file']">
		<xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
			<xsl:attribute name="parse">xml</xsl:attribute>
			<xsl:attribute name="href" select="@name" />
			<xsl:element name="fallback" namespace="http://www.w3.org/2001/XInclude">
				<xsl:value-of select="@name" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>