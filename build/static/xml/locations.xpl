<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="1.0"
	type="tcy:static-location-xml">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates custom XML documents for the static web view of location data.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing source game data.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/static/xml/game/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the parent directory into which the source directory should be copied.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/static/xml</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
	<p:output port="result" sequence="true">
		<p:pipe step="results" port="result"/>
	</p:output>
	
	<p:documentation>
		<d:doc>
			<d:desc>Generate a listing of the game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$href"/>
		<p:with-option name="include-filter" select="'.*\.xml'" />
		<p:with-option name="exclude-filter" select="'game.xml'" />
	</p:directory-list>
	
	
	<p:documentation>
		<d:doc>
			<d:desc>
				<d:p>Iterate through the game data files.</d:p>
				<d:p>For each game, generate a custom XML document for each location on its map.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	<p:for-each name="process-games">
		
		<p:iteration-source select="c:directory/*:file">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:group name="process-game">

			<p:documentation>
				<d:doc scope="step">
					<d:desc>Determine the name of the source file.</d:desc>
				</d:doc>
			</p:documentation>
			<p:variable name="filename" select="c:file/@name" />

			<p:variable name="source-file-path" select="concat($href, '/', $filename)" />
			
			<p:load name="game-data" dtd-validate="false">
				<p:with-option name="href" select="$source-file-path" />
			</p:load>
			
			<p:group>
				
			
			<p:variable name="game-id" select="/game/@id">
				<p:pipe port="result" step="game-data" />
			</p:variable>
			
			<p:for-each name="process-location">
				
				<p:iteration-source select="/game/map//(country | location)[@id]">
					<p:pipe port="result" step="game-data" />
				</p:iteration-source>
			
				<p:group>
					
					<p:variable name="location-id" select="*/@id">
						<p:pipe port="current" step="process-location"></p:pipe>
					</p:variable>
					
					<p:xslt name="generate-xml">
						<p:input port="source">
							<p:pipe port="result" step="game-data" /> 
						</p:input>
						<p:input port="stylesheet">
							<p:document href="location.xsl" />
						</p:input>
						<p:with-param name="location-id" select="$location-id" />
					</p:xslt>
					
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Store the new location XML document.</d:desc>
						</d:doc>
					</p:documentation>
					<p:store name="store" 
						indent="true" 
						omit-xml-declaration="false" 
						encoding="utf-8" 
						method="xml" 
						media-type="text/xml">
						<p:with-option name="href" select="concat($target, '/', $game-id, '-', $location-id, '.xml')" />
					</p:store>
					
					
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
					
				</p:group>
				
			</p:for-each>
					
			</p:group>
		</p:group>
		
	</p:for-each>
	
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of paths to the updated game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />

	
</p:declare-step>