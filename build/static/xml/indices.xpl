<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:static-xml-indices"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates an XML view of data held about TTR maps.</d:p>
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
	<p:option name="href" required="true" />
	
	
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="process-directories" />
	</p:output>
	
	
	<p:documentation >
		<d:doc>
			<d:desc>Generate a listing of directories in the root of the static XML collection.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$href"/>
	</p:directory-list>
	

	<p:for-each name="process-directories">
		
		<p:iteration-source select="c:directory/c:directory">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:output port="result" sequence="true">
			<p:pipe port="result" step="generate-index" />
		</p:output>
		
		<p:group name="generate-index">
			
			<p:output port="result" sequence="true">
				<p:pipe port="result" step="store" />
			</p:output>
			
			<p:variable name="directory-path" select="c:directory/@xml:base">
				<p:pipe port="result" step="directory-listing" />
			</p:variable>
			
			<p:variable name="directory-name" select="c:directory/@name">
				<p:pipe port="current" step="process-directories" />
			</p:variable>
	
			<p:xquery name="generate-xml">
				<p:input port="source" select="/">
					<p:pipe port="current" step="process-directories" />
				</p:input>
				<p:input port="query">
					<p:inline>
						<c:query>
							<![CDATA[
								xquery version "1.0";
								declare namespace c="http://www.w3.org/ns/xproc-step";
								declare namespace xs="http://www.w3.org/2001/XMLSchema";
								
								declare variable $href as xs:string external;
								declare variable $directory-name as xs:string external;
								
								element {concat($directory-name, 's')}{
									for $document in collection($href)/*
									let $mode := string(node-name($document))
									let $id := $document/@id
									return
										element {$mode}{
											attribute {'id'} {$id},
											$document/*[name() = ('title', 'name')],
											$document/games
										}
								}
							]]>
						</c:query>
					</p:inline>		
				</p:input>
				<p:with-param name="href" select="concat($directory-path, '/', $directory-name, '/')"/>
				<p:with-param name="directory-name" select="$directory-name" />
			</p:xquery>
						
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Store the index data.</d:desc>
				</d:doc>
			</p:documentation>
			<p:store name="store"
				method="xml"
				encoding="utf-8"
				media-type="text/xml"
				indent="true" 
				omit-xml-declaration="false"
				version="1.0">
				<p:input port="source">
					<p:pipe port="result" step="generate-xml" />
				</p:input>
				<p:with-option name="href" select="concat($directory-path, '/', $directory-name, '/index.xml')" />
			</p:store>
		
		</p:group>
		
	</p:for-each>
	
</p:declare-step>