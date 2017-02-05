<?xml version="1.0" encoding="UTF-8"?>
<p:pipeline
	xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:d="http://ns.kaikoda.com/documentation/xml"
	version="1.0">
	
	<p:documentation>
		<d:doc scope="pipeline">
			<d:desc>
				<d:p>Parses map and ticket data from the board and card SVG files.</d:p>
			</d:desc>
			<d:note>
				<d:ul>
					<d:ingress>See documentation in:</d:ingress>
					<d:li>extract_and_merge_tickets.xsl</d:li>
					<d:li>extract_and_merge_map.xsl</d:li>
					<d:egress>for assumptions about the input files.</d:egress>
				</d:ul>
			</d:note>
			<d:note date="20170204">
				<d:ul>
					<d:ingress>This pipeline is currently unable to parse the following from the SVG:</d:ingress>
					<d:li>the length of a route</d:li>
					<d:li>the colour of a route</d:li>
					<d:li>the route type (eg. normal, tunnel, ferry, etc.)</d:li>
					<d:li>whether, and how many, locomotive cards are required to claim a route</d:li>
				</d:ul>
				<d:p>This data needs to be manually added prior to running the enhance_data pipeline.</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Extract location and route information from the board SVG file.</d:desc>
		</d:doc>
	</p:documentation>
	<p:xslt name="extract-map"> 
		<p:input port="source">
			<p:document href="../images/map/west_dorset/board/board.svg" />
		</p:input>
		<p:input port="stylesheet"> 
			<p:document href="../data/generate/extract_and_merge_map.xsl"/> 
		</p:input> 
	</p:xslt> 
	

	<p:documentation>
		<d:doc scope="step">
			<d:desc>Wrap the game data parsed so far in a temporary binder element.</d:desc>
		</d:doc>
		<d:note>
			<d:p>The card SVG data is appended into the binder in the next step.</d:p>
		</d:note>
	</p:documentation>
	<p:insert name="merge-map-result-into-binder" match="/*" position="first-child">
		<p:input port="source" select="/">
			<p:inline>
				<temp:binder xmlns:temp="http://ns.thecodeyard.co.uk/xproc/temp" />
			</p:inline>
		</p:input>
		<p:input port="insertion" select="/">
			<p:pipe port="result" step="extract-map" />
		</p:input>
	</p:insert>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Append the card SVG into a temporary binder element that already contains game data parsed from board SVG.</d:desc>
		</d:doc>
	</p:documentation>
	<p:insert name="merge-cards-svg-into-binder" match="/*" position="last-child">
		<p:input port="source" select="/">		
			<p:pipe port="result" step="merge-map-result-into-binder" />
		</p:input>
		<p:input port="insertion" select="/*">			
			<p:document href="../images/map/west_dorset/cards/cards.svg" />
		</p:input>
	</p:insert>
	
	
	<p:documentation>
		<d:doc scope="step">
			<d:desc>Extract ticket information from the cards SVG file.</d:desc>
			<d:note>
				<d:p>During prior steps (merge-map-result-into-binder, merge-cards-svg-into-binder), the card SVG and game data parsed from board SVG have been temporarily bound together into a single XML document so that they can be passed together into this XSLT step.</d:p>
			</d:note>
		</d:doc>
	</p:documentation>
	<p:xslt name="extract-tickets"> 
		<p:input port="source">
			<p:pipe port="result" step="merge-cards-svg-into-binder" />
		</p:input>
		<p:input port="stylesheet"> 
			<p:document href="../data/generate/extract_and_merge_tickets.xsl"/> 
		</p:input> 
	</p:xslt> 
	
</p:pipeline>