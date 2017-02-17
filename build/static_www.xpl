<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
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
				<d:p>For example: file:///projects/greenwood/data/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="source-data-path" required="true" />
	
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
				<d:p>For example: file:///projects/greenwood/dist/www/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="output-path" required="true" />
	
	
	<p:import href="html/recursive-copy-directory.xpl" />
	<p:import href="html/game.xpl" />

	<p:group>
	
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Copy javascript assets that the result will depend on to the output directory.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:recursive-copy-directory name="copy-dependencies-js">
			<p:with-option name="href" select="'file:///home/sheila/repositories/git/greenwood/analysis/www/js/'" />
			<p:with-option name="target" select="concat($output-path, '/js/')" />
		</tcy:recursive-copy-directory>
		
		
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Copy style assets that the result will depend on to the output directory.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:recursive-copy-directory name="copy-dependencies-style">
			<p:with-option name="href" select="'file:///home/sheila/repositories/git/greenwood/analysis/www/style/'" />
			<p:with-option name="target" select="concat($output-path, '/style/')" />
		</tcy:recursive-copy-directory>
	
	</p:group>
	
	
	<p:documentation>
		<d:doc>
			<d:desc>Generate a listing of the XML files in the directory referenced by $source-data-path.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$source-data-path"/>
		<p:with-option name="include-filter" select="'.*\.xml'"/>
		<p:with-option name="exclude-filter" select="'game.xml'" />
	</p:directory-list>
	

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
	<p:for-each name="get-source">
		
		<p:iteration-source select="c:directory/c:file">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:group name="process-game">
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Determine the name of the source file.</d:desc>
				</d:doc>
			</p:documentation>
			<p:variable name="filename" select="c:file/@name" />
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Determine a path to the directory containing the source file.</d:desc>
				</d:doc>
			</p:documentation>
			<p:variable name="directory-path" select="c:directory/@xml:base">
				<p:pipe port="result" step="directory-listing" />
			</p:variable>
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Determine a path to the source file.</d:desc>
				</d:doc>
			</p:documentation>
			<p:variable name="file-path" select="concat($directory-path, '/', $filename)" />
			
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Generate a summary of the game data.</d:desc>
				</d:doc>
			</p:documentation>
			<tcy:view-game-html>
				<p:with-option name="source" select="$file-path" />
				<p:with-option name="stylesheet-dir" select="$html-xslt-path" />
				<p:with-option name="target" select="$output-path" />
			</tcy:view-game-html>
			
		</p:group>
		
	</p:for-each>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of paths to the updated game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />
	
</p:pipeline>