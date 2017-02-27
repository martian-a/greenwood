<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:generate-static-xml"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates custom XML views of data held about TTR maps.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing the existing game data file(s).</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/data/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where output results should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/xml/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
	
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="copy-game-xml" />
		<p:pipe port="result" step="generate-location-xml" />
		<p:pipe port="result" step="generate-index-xml" />
	</p:output> 
	
	<p:import href="game.xpl" />
	<p:import href="locations.xpl" />
	<p:import href="indices.xpl" />

	<p:documentation>
		<d:doc scope="step">
			<d:desc>Copy game data files to the output directory.</d:desc>
		</d:doc>
	</p:documentation>
	<tcy:static-game-xml name="copy-game-xml">
		<p:with-option name="href" select="$href" />
		<p:with-option name="target" select="concat($target, '/game/')" />
	</tcy:static-game-xml>
		

	<p:documentation>
		<d:doc scope="step">
			<d:desc>Generate custom location XML files and store them in the output directory.</d:desc>
		</d:doc>
	</p:documentation>
	<tcy:static-location-xml name="generate-location-xml">
		<p:with-option name="href" select="concat($target, '/game/')" />
		<p:with-option name="target" select="concat($target, '/location/')" />
	</tcy:static-location-xml>
		
		
		
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Generate custom index XML files and store them in the output directory.</d:desc>
		</d:doc>
	</p:documentation>
	<tcy:static-xml-indices name="generate-index-xml">
		<p:with-option name="href" select="$target" />
	</tcy:static-xml-indices>	
	
</p:declare-step>