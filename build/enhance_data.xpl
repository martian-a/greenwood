<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	version="2.0">
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Calculates the shortest paths between locations on the map and appends the results to existing game data.</d:p>
			</d:desc>
			<d:note>
				<d:ul>
					<d:ingress>See documentation in:</d:ingress>
					<d:li>network.xsl</d:li>
					<d:li>shortest_paths.xsl</d:li>
					<d:egress>for assumptions about the input files.</d:egress>
				</d:ul>
			</d:note>
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
			<d:desc>Whether the routes for shortest paths between nodes should be recorded (true) or just the distance (false).</d:desc>
		</d:doc>
	</p:documentation>
	<p:option name="route" required="true" as="xs:boolean" />
	
	
	<p:documentation>
		<d:doc>
			<d:desc>Generate a listing of the XML files in the directory referenced by $href.</d:desc>
		</d:doc>
	</p:documentation>
	<p:directory-list name="directory-listing">
		<p:with-option name="path" select="$href"/>
		<p:with-option name="include-filter" select="'.*\.xml'"/>
		<p:with-option name="exclude-filter" select="'game.xml'" />
	</p:directory-list>


	<p:documentation>
		<d:doc>
			<d:desc>
				<d:p>Iterate through the list of files returned by the directory-listing step.</d:p>
				<d:ul>
					<d:ingress>For each data file:</d:ingress>
					<d:li>delete any existing shortest path data in the source document</d:li>
					<d:li>generate a simplified view of the map as a network (nodes, edges)</d:li>
					<d:li>calculate the shortest paths between the nodes</d:li>
					<d:li>insert the newly calculated shortest path data into the source document</d:li>
					<d:li>save the updated source document</d:li>
				</d:ul>
			</d:desc>
		</d:doc>
	</p:documentation>
	<p:for-each name="get-source">
		
		<p:iteration-source select="c:directory/c:file">
			<p:pipe port="result" step="directory-listing" />
		</p:iteration-source>
		
		<p:group name="insert-shortest-paths">
			
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
					<d:desc>Load existing game data, containing the locations on the map and routes between them.</d:desc>
				</d:doc>
			</p:documentation>
			<p:load name="existing-data">
				<p:with-option name="href" select="$file-path" />
			</p:load>


			<p:documentation>
				<d:doc scope="step">
					<d:desc>Remove any existing shortest path data from the existing game data.</d:desc>
				</d:doc>
			</p:documentation>
			<p:delete match="/game/map/shortest-paths" name="remove-existing-shortest-paths">
				<p:input port="source" select="/">
					<p:pipe port="result" step="existing-data" />
				</p:input>
			</p:delete>

	
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Generate a simplified view of the location and routes data as a network of nodes and edges.</d:desc>
				</d:doc>
			</p:documentation>
			<p:xslt name="generate-network"> 
				<p:input port="stylesheet"> 
					<p:document href="../data/generate/network.xsl"/> 
				</p:input> 
				<p:input port="source">
					<p:pipe port="result" step="remove-existing-shortest-paths" />
				</p:input>
			</p:xslt> 
			
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Use the simplified network view to calculate the shortest path between locations.</d:desc>
				</d:doc>
			</p:documentation>
			<p:xslt name="identify-shortest-paths"> 
				<p:input port="stylesheet"> 
					<p:document href="../data/generate/shortest_paths.xsl"/> 
				</p:input> 
				<p:input port="source">
					<p:pipe port="result" step="generate-network" />
				</p:input>
				<p:with-param name="route" select="$route" />
			</p:xslt> 
			
			
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Merge the shortest path data into the existing game data.</d:desc>
				</d:doc>
			</p:documentation>
			<p:insert match="/game/map" position="last-child" name="append">
				<p:input port="source" select="/">
					<p:pipe port="result" step="remove-existing-shortest-paths" />
				</p:input>
				<p:input port="insertion" select="/game/map/shortest-paths">
					<p:pipe port="result" step="identify-shortest-paths" />
				</p:input>
			</p:insert>
		 
		 	
			<p:documentation>
				<d:doc scope="step">
					<d:desc>Store the updated game data.</d:desc>
				</d:doc>
			</p:documentation>
			<p:store name="store" 
				indent="true" 
				doctype-system="game.dtd" 
				omit-xml-declaration="false" 
				encoding="utf-8" 
				method="xml" 
				media-type="text/xml">
				<p:with-option name="href" select="$file-path" />
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
			
		</p:group>
		
	</p:for-each>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Return a list of paths to the updated game data files.</d:desc>
		</d:doc>
	</p:documentation>
	<p:wrap-sequence name="results" wrapper="c:results" />

</p:pipeline>