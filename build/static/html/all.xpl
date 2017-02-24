<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:generate-static-html"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates an HTML view of data held about TTR maps.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing the existing game data file(s).</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/build/static/xml/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="source-data-path" required="true" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing dependencies, such as JS and CSS.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/app/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="source-dependencies-path" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing XSLT for generating the HTML views.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/www/xslt/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="html-xslt-path" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where output results should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/html/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="output-path" required="true" />
	
	
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="copy-dependencies" />
		<p:pipe port="result" step="process-directories" />
	</p:output>
	
	
	<p:import href="copy_dependencies.xpl" />


	<p:documentation>
		<d:doc scope="step">
			<d:desc>Copy javascript assets that the result will depend on the output directory.</d:desc>
		</d:doc>
	</p:documentation>
	<tcy:copy-dependencies name="copy-dependencies">
		<p:with-option name="href" select="$source-dependencies-path" />
		<p:with-option name="target" select="$output-path" />
	</tcy:copy-dependencies>

	<p:sink />
		
	<p:documentation >
		<d:doc>
			<d:desc>Generate a listing of the XML files in the directory referenced by $source-data-path.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$source-data-path"/>
	</p:directory-list>
	
	<p:sink />
	
	<p:documentation>
		<d:doc>
			<d:desc>
				<d:p>Iterate through the list of files returned by the directory-listing step.</d:p>
				<d:ul>
					<d:ingress>For each data file:</d:ingress>
					<d:li>generate an HTML summary of the game data</d:li>
					<d:li>generate an HTML summary of every location in the game</d:li>
				</d:ul>
			</d:desc>
		</d:doc>
	</p:documentation>
	<p:for-each name="process-directories">
		
		<p:iteration-source select="c:directory/c:directory">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:output port="result" sequence="true">
			<p:pipe port="result" step="process-files" />
		</p:output>
		
		<p:group name="process-files">
			
			<p:output port="result" sequence="true">
				<p:pipe port="result" step="process-file" />
			</p:output>
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Determine the name of the directory.</d:desc>
				</d:doc>
			</p:documentation>
			<p:variable name="directory-name" select="c:directory/@name">
				<p:pipe port="current" step="process-directories" />
			</p:variable>
			
			
			<p:documentation >
				<d:doc>
					<d:desc>Generate a listing of the XML files in the directory referenced by $source-data-path.</d:desc>
				</d:doc>
			</p:documentation>
			<p:directory-list name="file-listing">
				<p:with-option name="path" select="concat($source-data-path, '/', $directory-name, '/')"/>
				<p:with-option name="include-filter" select="'.*\.xml'"/>
			</p:directory-list>
		
		
			<p:for-each name="process-file">
		
				<p:iteration-source select="c:directory/c:file">
					<p:pipe port="result" step="file-listing" />
				</p:iteration-source>
				
				<p:output port="result" sequence="true">
					<p:pipe port="result" step="generate-html" />
				</p:output>
				
				<p:group name="generate-html">
					
					<p:output port="result">
						<p:pipe port="result" step="results" />
					</p:output>

					<p:documentation>
						<d:doc scope="step">
							<d:desc>Determine the name of the source file.</d:desc>
						</d:doc>
					</p:documentation>
					<p:variable name="filename" select="c:file/@name">
						<p:pipe port="current" step="process-file" />
					</p:variable>
					
					<p:variable name="directory-path" select="c:directory/@xml:base">
						<p:pipe port="result" step="file-listing" />
					</p:variable>

					<p:variable name="file-path" select="concat($directory-path, '/', $filename)" />
					
					<p:variable name="stylesheet-name" select="if ($directory-name = 'game') then 'game.xsl' else 'location.xsl'" />
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Load stylesheet for generating a static HTML view of TTR game data.</d:desc>
						</d:doc>
					</p:documentation>
					<p:load name="stylesheet">
						<p:with-option name="href" select="concat($source-dependencies-path, '/xslt/', $stylesheet-name)" />
					</p:load>
					
					<p:sink />		
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Load game data for generating a static HTML view of TTR game data.</d:desc>
						</d:doc>
					</p:documentation>
					<p:load name="data">
						<p:with-option name="href" select="$file-path" />
					</p:load>	
					
					<p:sink />
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Generate a summary of the game data.</d:desc>
						</d:doc>
					</p:documentation>
					<p:xslt name="generate-summary"> 
						<p:input port="stylesheet"> 
							<p:pipe port="result" step="stylesheet" />
						</p:input> 
						<p:input port="source">
							<p:pipe port="result" step="data" />
						</p:input>
						<p:with-param name="path-to-js" select="'../../js'" />
						<p:with-param name="path-to-css" select="'../../style'" />
						<p:with-param name="path-to-xml" select="'../../xml'" />
					</p:xslt> 
					
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Store the HTML view of the game.</d:desc>
						</d:doc>
					</p:documentation>
					<p:store name="store"
						method="html"
						encoding="utf-8"
						media-type="text/html"
						indent="true" 
						omit-xml-declaration="true"
						version="5">
						<p:input port="source">
							<p:pipe port="result" step="generate-summary" />
						</p:input>
						<p:with-option name="href" select="concat($output-path, '/html/', $directory-name, '/', substring-before($filename, '.xml'), '.html')" />
					</p:store>
					
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Return a path to where the game HTML has been stored.</d:desc>
						</d:doc>
					</p:documentation>
					<p:identity name="results">
						<p:input port="source">
							<p:pipe port="result" step="store" />
						</p:input>
					</p:identity>
				</p:group>
				

			</p:for-each>
			
		</p:group>
		
	</p:for-each>

	
</p:declare-step>