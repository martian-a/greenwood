<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	type="tcy:delete-static-site"
	version="2.0">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Deletes existing static site from distribution directory.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory containing the existing static site.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/data/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	<p:output port="result" primary="true" />
	
	<p:import href="../utils/recursive_delete_directory.xpl"/>


	<tcy:recursive-delete-directory>
		<p:with-option name="href" select="$href" />
	</tcy:recursive-delete-directory>
			

	<p:wrap-sequence wrapper="c:deleted" />
	
	
</p:declare-step>