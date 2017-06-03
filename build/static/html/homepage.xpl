<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:generate-static-html-publish-homepage"
	name="publish-homepage"
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
	<p:option name="href-xml" required="true" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing dependencies, such as JS, CSS and XSLT.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/app/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href-app" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where output results should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
	
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="results" />
	</p:output>
	

		
	<p:variable name="stylesheet-name" select="'global.xsl'" />
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Load stylesheet for generating a static HTML view of this file.</d:desc>
		</d:doc>
	</p:documentation>
	<p:load name="stylesheet">
		<p:with-option name="href" select="concat($href-app, 'xslt/', $stylesheet-name)" />
	</p:load>
	
	<p:sink />		
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Load the current data file.</d:desc>
		</d:doc>
	</p:documentation>
	<p:load name="data">
		<p:with-option name="href" select="$href-xml" />
	</p:load>	
	
	<p:sink />
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Generate an HTML view of the data.</d:desc>
		</d:doc>
	</p:documentation>
	<p:xslt name="generate-summary"> 
		<p:input port="stylesheet"> 
			<p:pipe port="result" step="stylesheet" />
		</p:input> 
		<p:input port="source">
			<p:pipe port="result" step="data" />
		</p:input>
		<p:with-param name="path-to-js" select="'../js'" />
		<p:with-param name="path-to-css" select="'../style'" />
		<p:with-param name="path-to-xml" select="'../xml'" />
		<p:with-param name="path-to-html" select="'../html'" />
		<p:with-param name="path-to-images" select="'../images'" />
		<p:with-param name="static" select="'true'" />
	</p:xslt> 
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Store the HTML view of the data.</d:desc>
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
		<p:with-option name="href" select="concat($target, '/html/index.html')" />
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
	
	
</p:declare-step>