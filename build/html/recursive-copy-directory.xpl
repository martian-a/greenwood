<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="1.0"
	type="tcy:recursive-copy-directory">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Copies an entire directory and its contents to the destination specified.</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory to be copied.</d:desc>
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
				<d:p>For example: file:///projects/greenwood/dist/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="target" required="true" />

	<p:output port="result">
		<p:pipe step="results" port="result"/>
	</p:output>
	
	<p:import href="http://xmlcalabash.com/extension/steps/fileutils.xpl"/>
	
	<p:documentation>
		<d:doc>
			<d:desc>Generate a listing of the contents of the directory referenced by $href.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$href"/>
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
		
		<p:iteration-source select="c:directory/*">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:group name="copy-file">
			
			<p:choose>
				
				<p:when test="*[local-name() = 'file']">
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Determine the name of the source file.</d:desc>
						</d:doc>
					</p:documentation>
					<p:variable name="filename" select="c:file/@name" />
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Determine a path to the source file.</d:desc>
						</d:doc>
					</p:documentation>
					<p:variable name="source-file-path" select="concat($href, '/', $filename)" />
					
					<cxf:copy name="copy">
						<p:with-option name="href" select="$source-file-path" />
						<p:with-option name="target" select="concat($target, '/', $filename)" />
					</cxf:copy>
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Return a path to where the updated game data has been stored.</d:desc>
						</d:doc>
					</p:documentation>
					<p:identity>
						<p:input port="source">
							<p:pipe port="result" step="copy" />
						</p:input>
					</p:identity>
					
				</p:when>
				
				<p:when test="*[local-name() = 'directory']">
					
					<p:documentation>
						<d:doc scope="step">
							<d:desc>Determine the name of the source directory.</d:desc>
						</d:doc>
					</p:documentation>
					<p:variable name="directory-name" select="c:directory/@name" />
					
					<tcy:recursive-copy-directory>
						<p:with-option name="href" select="concat($href, '/', $directory-name)" />
						<p:with-option name="target" select="concat($target, '/', $directory-name)" />
					</tcy:recursive-copy-directory>
					
				</p:when>
				
				<p:otherwise>
					<p:identity />
				</p:otherwise>
				
			</p:choose>

		</p:group>
		
	</p:for-each>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of paths to the updated game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />

</p:declare-step>