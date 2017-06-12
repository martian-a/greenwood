<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:generate-xincluded-data"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates a copy of the core data files with all xincludes resolved.</d:p>
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
				<d:p>For example: file:///projects/greenwood/dist/data/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
	
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="reset" />
		<p:pipe port="result" step="copy-game-xml" />
	</p:output> 
	
	<p:import href="http://xmlcalabash.com/extension/steps/fileutils.xpl"/>
	<p:import href="utils/recursive_delete_directory.xpl"/>
	<p:import href="static/delete_static_site.xpl"/>
	<p:import href="static/xml/game.xpl" />

	<p:group name="reset">
		
		<p:output port="result">
			<p:pipe port="result" step="create-target-dir" />
		</p:output>
		
		<!-- Ensure that the target directory exists before
					attempting to delete any prexisting results
					otherwise, if it doesn't exist, the pipeline 
					fails.-->
		<!-- TODO: find a better way to test whether the 
					directory exists and if it doesn't, simply 
					skip delete step.-->
		<cxf:mkdir>
			<p:with-option name="href" select="$target" />
		</cxf:mkdir>
		
		<tcy:delete-static-site name="clean">
			<p:with-option name="href" select="$target" />	
		</tcy:delete-static-site>
		
		<p:sink />
		
		<cxf:mkdir name="create-target-dir">
			<p:with-option name="href" select="$target" />
		</cxf:mkdir>
		
	</p:group>
	
	<p:sink />
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Copy game data files to the output directory.</d:desc>
		</d:doc>
	</p:documentation>
	<tcy:static-game-xml name="copy-game-xml">
		<p:with-option name="href" select="$href" />
		<p:with-option name="target" select="$target" />
		<p:with-option name="static" select="false()" />
	</tcy:static-game-xml>
		
</p:declare-step>