<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="1.0"
	type="tcy:static-game-xml">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Copies game XML files to the destination specified.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing the game XML files to be copied.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/data/</d:p>
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
	
	<p:documentation>
		<p:doc>
			<d:desc>Whether the output is intended for distribution via the static site. (true|false)</d:desc>
			<d:note>
				<d:p>This affects which fame files are included in the output.</d:p>
			</d:note>
		</p:doc>
	</p:documentation>
	<p:option name="static" select="true()" />
	
	<p:output port="result">
		<p:pipe step="results" port="result"/>
	</p:output>
	
	<p:documentation>
		<d:doc>
			<d:desc>Generate a listing of the contents of the directory referenced by $href.</d:desc>
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
				<d:p>Iterate through the result returned by the directory-listing step.</d:p>
				<d:p>For each file or directory, make a copy in the same location, relative to the $target directory.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	<p:for-each name="copy-files">
		
		<p:iteration-source select="c:directory/*:file">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:group name="copy-file">

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
				
				<p:variable name="publish" select="/game/@publish">
					<p:pipe port="result" step="game-data" />
				</p:variable>
				
				<p:choose>
					<p:when test="($static = true() and $publish = true()) or $static = false()">
						
						<p:variable name="game-id" select="/game/@id">
							<p:pipe port="result" step="game-data" />
						</p:variable>
						
						<p:documentation>
							<d:doc scope="step">
								<d:desc>Store the game data.</d:desc>
							</d:doc>
						</p:documentation>
						<p:store name="store" 
							indent="true" 
							omit-xml-declaration="false" 
							encoding="utf-8" 
							method="xml" 
							media-type="text/xml">
							<p:input port="source">
								<p:pipe port="result" step="game-data" />
							</p:input>
							<p:with-option name="href" select="concat($target, '/', $game-id, '.xml')" />
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
						
						<p:wrap match="/" wrapper="included" />
						
					</p:when>
					<p:otherwise>
						
						<p:identity>
							<p:input port="source">
								<p:pipe port="current" step="copy-files" />
							</p:input>
						</p:identity>
						
						<p:wrap match="/" wrapper="excluded" />
						
					</p:otherwise>
				</p:choose>

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