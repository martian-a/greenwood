<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="1.0"
	type="tcy:static-homepage-xml">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Creates a custom XML file from which the site homepage will be generated.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing game XML files to be included.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/data/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the parent directory into which the homepage XML file should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/static/xml</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
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
		<p:with-option name="exclude-filter" select="'index.xml'" />
	</p:directory-list>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Load stylesheet for generating a static HTML view of this file.</d:desc>
		</d:doc>
	</p:documentation>
	<p:load name="stylesheet">
		<p:with-option name="href" select="'homepage.xsl'" />
	</p:load>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Generate a single xml file from the source files provided.</d:desc>
		</d:doc>
	</p:documentation>
	<p:xslt name="generate-xml"> 
		<p:input port="stylesheet"> 
			<p:pipe port="result" step="stylesheet" />
		</p:input> 
		<p:input port="source">
			<p:pipe port="result" step="directory-listing" />
		</p:input>
		<p:input port="parameters">
			<p:empty />
		</p:input>
	</p:xslt> 
	

	<p:documentation>
		<d:doc scope="step">
			<d:desc>Store the xinclude file.</d:desc>
		</d:doc>
	</p:documentation>
	<p:store name="store" 
		indent="true" 
		omit-xml-declaration="false" 
		encoding="utf-8" 
		method="xml" 
		media-type="text/xml">
		<p:input port="source">
			<p:pipe port="result" step="generate-xml" />
		</p:input>
		<p:with-option name="href" select="concat($target, '/index.xml')" />
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
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of paths to the updated game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />
	
</p:declare-step>