<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="2.0"
	type="tcy:copy-dependencies">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Generates an HTML view of data held about TTR maps.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where the dependencies are stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/app/html/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory where output results should be stored.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/html/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />
	
	
	<p:output port="result" sequence="true" />
	
	<p:import href="../../recursive_copy_directory.xpl" />

	<p:group name="copy-dependencies">
	
		<p:output port="result" sequence="true">
			<p:pipe port="result" step="copy-dependencies-js" />
			<p:pipe port="result" step="copy-dependencies-style" />
		</p:output>
	
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Copy javascript assets that the result will depend on to the output directory.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:recursive-copy-directory name="copy-dependencies-js">
			<p:with-option name="href" select="concat($href, '/js/')" />
			<p:with-option name="target" select="concat($target, '/js/')" />
		</tcy:recursive-copy-directory>
		
		
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Copy style assets that the result will depend on to the output directory.</d:desc>
			</d:doc>
		</p:documentation>
		<tcy:recursive-copy-directory name="copy-dependencies-style">
			<p:with-option name="href" select="concat($href, '/style/')" />
			<p:with-option name="target" select="concat($target, '/style/')" />
		</tcy:recursive-copy-directory>
		
		
	</p:group>

	
</p:declare-step>