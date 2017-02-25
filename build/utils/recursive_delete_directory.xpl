<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:cxf="http://xmlcalabash.com/ns/extensions/fileutils"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	xmlns:tcy="http://ns.thecodeyard.co.uk/xproc/step"
	version="1.0"
	type="tcy:recursive-delete-directory">
	
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Deletes an entire directory and its contents (including sub-directories and their contents).</d:p>
			</d:desc>
		</d:doc>
	</p:documentation>
	
	<p:documentation>
		<d:doc>
			<d:desc>A URL to the directory to be deleted.</d:desc>
			<d:note>
				<d:p>For example: file:///projects/greenwood/dist/www/</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:option name="href" required="true" />
	
	<p:option name="fail-on-error" select="false()" />
	
	<p:output port="result" primary="true">
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
	
	<p:group>	
		
		<p:variable name="directory-path" select="c:directory/@xml:base">
			<p:pipe port="result" step="directory-listing"></p:pipe>
		</p:variable>
		
		<p:documentation>
			<d:doc>
				<d:desc>
					<d:p>Iterate through the result returned by the directory-listing step.</d:p>
					<d:p>Delete each file and directory.</d:p>
				</d:desc>
			</d:doc>
		</p:documentation>
		<p:for-each name="delete-items">
			
			<p:iteration-source select="c:directory/*">
				<p:pipe port="result" step="directory-listing" />
			</p:iteration-source>
			
			<p:output port="result" sequence="true" />
			
			<p:group name="delete-item">
				
				<p:choose>
					
					<p:when test="*[local-name() = 'file']">
						
						<p:documentation>
							<d:doc scope="step">
								<d:desc>Determine the name of the source file.</d:desc>
							</d:doc>
						</p:documentation>
						<p:variable name="filename" select="c:file/@name" />
						
						<cxf:delete name="delete">
							<p:with-option name="href" select="concat($directory-path, '/', $filename)" />
							<!-- p:with-option name="recursive" select="'false'" / -->
							<p:with-option name="fail-on-error" select="$fail-on-error" />
						</cxf:delete>
						
						<p:documentation>
							<d:doc scope="step">
								<d:desc>Return the deleted file's former path.</d:desc>
							</d:doc>
						</p:documentation>
						<p:identity>
							<p:input port="source">
								<p:pipe port="result" step="delete" />
							</p:input>
						</p:identity>
						
					</p:when>
					
					<p:when test="*[local-name() = 'directory']">
						
						<p:documentation>
							<d:doc scope="step">
								<d:desc>Determine the name of the directory.</d:desc>
							</d:doc>
						</p:documentation>
						<p:variable name="directory-name" select="c:directory/@name" />
						
						<tcy:recursive-delete-directory>
							<p:with-option name="href" select="concat($directory-path, '/', $directory-name)" />
						</tcy:recursive-delete-directory>
						
					</p:when>
					
					<p:otherwise>
						<p:identity />
					</p:otherwise>
					
				</p:choose>
				
			</p:group>
			
		</p:for-each>	
		
		<p:sink />
		
		<cxf:delete name="delete-current-directory">
			<p:with-option name="href" select="$directory-path" />
			<!-- p:with-option name="recursive" select="'false'" / -->
			<p:with-option name="fail-on-error" select="$fail-on-error" />
		</cxf:delete>
		
		<p:documentation>
			<d:doc scope="step">
				<d:desc>Return the deleted file's former path.</d:desc>
			</d:doc>
		</p:documentation>
		<p:identity>
			<p:input port="source">
				<p:pipe port="result" step="delete-items" />
				<p:pipe port="result" step="delete-current-directory" />
			</p:input>
		</p:identity>	
	
	</p:group>
	

	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of the deleted files and directories.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />

</p:declare-step>