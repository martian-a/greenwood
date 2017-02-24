<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates a static snapshot (XML, HTML) of content in the TTR analysis app.</d:p>
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
	<p:option name="href-data" required="true" />
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing the analysis app file(s).</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/analysis/www/</d:p>
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
	
	<p:import href="static/xml/all.xpl" />
	<p:import href="static/html/all.xpl" />

	<p:group>
		
		<p:output port="result" sequence="true">
			<p:pipe port="result" step="generate-xml" />
			<p:pipe port="result" step="generate-html" />
		</p:output>
	
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Generate a snapshot of the XML that would currently be returned by the analysis app.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:generate-static-xml name="generate-xml">
			<p:with-option name="href" select="$href-data" />
			<p:with-option name="target" select="concat($target, '/xml/')" />
		</tcy:generate-static-xml>
			
		<p:sink />
			
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Generate a snapshot of the HTML that would currently be returend by the analysis app.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:generate-static-html name="generate-html">
			<p:with-option name="href-data" select="concat($target, '/xml/')" />
			<p:with-option name="href-app" select="$href-app" />
			<p:with-option name="target" select="$target" />
		</tcy:generate-static-html>
	
	</p:group>
	
	<p:wrap-sequence wrapper="c:results" />
	
</p:pipeline>