<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:view-game-html"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates an HTML view of data about a TTR game.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to a file containing the game XML.</d:desc>
		</d:doc>
	</p:documentation>
	<p:option name="source" required="true" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to a directory containing stylesheets for generating static HTML views of TTR game data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:option name="stylesheet-dir" required="true" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where output results should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
			
			
			
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Load stylesheet for generating a static HTML view of TTR game data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:load name="view-game-xslt">
		<p:with-option name="href" select="concat($stylesheet-dir, '/game.xsl')" />
	</p:load>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Load full game data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:load name="game-data">
		<p:with-option name="href" select="$source" />
	</p:load>
			
			
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Generate a summary of the game data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:xslt name="generate-game-summary"> 
		<p:input port="stylesheet"> 
			<p:pipe port="result" step="view-game-xslt" />
		</p:input> 
		<p:input port="source">
			<p:pipe port="result" step="game-data" />
		</p:input>
		<p:with-param name="path-to-js" select="'../js'" />
		<p:with-param name="path-to-css" select="'../style'" />
	</p:xslt> 
			
			
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Store the updated game data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:store name="store" 
		method="html"
		encoding="utf-8"
		media-type="text/html"
		indent="true" 
		omit-xml-declaration="true"
		version="5">
		<p:with-option name="href" select="concat($target, '/game/', //*[local-name() = 'game']/@id, '.html')">
			<p:pipe port="result" step="game-data" />
		</p:with-option>
	</p:store>
			
			<!--
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Generate a summary of the data for each location in the game.</d:desc>
				</d:doc>
			</p:documentation>
			<p:xslt name="generate-location-summary"> 
				<p:input port="stylesheet"> 
					<p:document href="xslt/location-summary.xsl"/> 
				</p:input> 
				<p:input port="source" select="//map/descendant::location">
					<p:pipe port="result" step="game-data" />
				</p:input>
			</p:xslt> 
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Store the updated game data.</d:desc>
				</d:doc>
			</p:documentation>
			<p:store name="store" 
				indent="true" 
				doctype-system="game.dtd" 
				omit-xml-declaration="false" 
				encoding="utf-8" 
				method="xml" 
				media-type="text/xml">
				<p:with-option name="href" select="concat($output-path, '/game/', $game-id, '.html'" />
			</p:store>
			-->
			
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a path to where the updated game data has been stored.</d:desc>
		</d:doc>
	</p:documentation>
	<p:identity>
		<p:input port="source">
			<p:pipe port="result" step="store" />
		</p:input>
	</p:identity>
	
</p:pipeline>