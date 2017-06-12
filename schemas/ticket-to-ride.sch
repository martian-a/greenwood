<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
	xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
	
	<sch:pattern>
		
		<sch:title>Collections</sch:title>
		
		<sch:rule context="/game">
			
			<sch:assert test="assets/collection/@id = 'SOU4'">Missing route options.  Add an asset collection representing route options.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU1'">Missing train card river.  Add an asset collection representing the train card river.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU2'">Missing train card draw pile.  Add an asset collection representing the train card draw pile.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU5'">Missing tickets draw pile.  Add an asset collection representing the tickets draw pile.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU9'">Missing train card discard pile.  Add an asset collection representing the train card discard pile.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU8'">Missing ticket discard pile.  Add an asset collection representing the ticket discard pile.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU6'">Missing players hand.  Add an asset collection representing the players hand.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU7'">Missing players tickets.  Add an asset collection representing the players tickets.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU10'">Missing players carriages.  Add an asset collection representing the players carriage tokens.</sch:assert>
			<sch:assert test="assets/collection/@id = 'SOU12'">Missing players points.  Add an asset collection representing the points accrued by players.</sch:assert>
			
			<sch:report test="assets/collection[not(ancestor::game/assets/collection/@id = 'SOU11')]/@id = 'SOU3'">Missing stations.  The locations and stations collections must either both be present or absent.  Add an asset collection representing players stations or remove the collection representing locations.</sch:report>
			<sch:report test="assets/collection[not(ancestor::game/assets/collection/@id = 'SOU3')]/@id = 'SOU11'">Missing locations.  The locations and stations collections must either both be present or absent.  Add an asset collection representing locations on the map or remove the collection representing players stations.</sch:report>
			
			<sch:report test="actions/action[not(ancestor::game/assets/collection/@id = 'SOU3')]/@id = 'ACT2'">Missing stations.  If the claim location action is present, the stations collections must be too.  Add an asset collection representing players stations or remove the claim location action.</sch:report>
			<sch:report test="actions/action[not(ancestor::game/assets/collection/@id = 'SOU11')]/@id = 'ACT2'">Missing locations.  If the claim location action is present, the locations collections must be too.  Add an asset collection representing locations on the map or remove the claim location action.</sch:report>			
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Actions</sch:title>
		
		<sch:rule context="/game">
			
			<sch:assert test="actions/action/@id = 'ACT1'">Missing action.  Add an action representing a player claiming a route.</sch:assert>
			<sch:report test="assets/collection[not(ancestor::game/actions/action/@id = 'ACT2')]/@id = ('SOU3', 'SOU11')">Missing action.  The locations and stations collections must only be present if it's possible to claim a location.  Add the claim location action or remove the collections representing locations and stations.</sch:report>
			<sch:assert test="actions/action/@id = 'ACT3'">Missing action.  Add an action representing a player drawing additional tickets.</sch:assert>
			<sch:assert test="actions/action/@id = 'ACT5'">Missing action.  Add an action representing a player drawing cards from the train card draw pile.</sch:assert>
			<sch:assert test="actions/action/@id = ('ACT4', 'ACT6')">Missing action.  Add an action representing a player drawing cards from the train card river.</sch:assert>
			
			<sch:report test="actions/action[ancestor::game/actions/action/@id = 'ACT4']/@id = 'ACT6'">Duplicate action.  There must be only one action representing a player drawing cards from the train card river.  Remove either ACT4 or ACT6.</sch:report>
			
			<sch:assert test="actions/action[not(@type = 'award')]/source">Missing source.  All actions (other than awards) must reference a source collection.  Add a reference to a source collection.</sch:assert>
			<sch:report test="actions/action[@type = 'award']/source">Unexpected source.  Awards actions must not reference a source collection.  Remove the reference to a source collection.</sch:report>
			
			<sch:assert test="actions/action/@type = 'award'">Missing award.  Each game must have at least one award action.  Add an award action.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Card draw piles</sch:title>
		
		<sch:rule context="assets/collection[@id = ('SOU1', 'SOU2', 'SOU5')]">
			
			<sch:let name="name" value="name" />
			
			<sch:assert test="self::*/@face-up">Missing face-up attribute.  Add a face-up attribute to the <sch:value-of select="$name" /> collection.</sch:assert>
				
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
	
		<sch:title>Card discard piles</sch:title>
		
		<sch:rule context="assets/collection[@id = ('SOU8', 'SOU9')]">
			
			<sch:let name="name" value="name" />
			
			<sch:assert test="self::*/@recycle">Missing recycle attribute.  Add a recycle attribute to the <sch:value-of select="$name" /> collection.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Starting hand</sch:title>
		
		<sch:rule context="assets/collection[@id = ('SOU6', 'SOU7', 'SOU10', 'SOU11')]">
			
			<sch:let name="name" value="name" />
			
			<sch:assert test="descendant::asset[not(asset)]/@init">Missing init attribute.  Check that all assets with no descendant assets, in the <sch:value-of select="$name" /> collection have an init attribute.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Set-up</sch:title>
		
		<sch:rule context="assets/collection[@id = ('SOU1')]">
			
			<sch:let name="name" value="name" />
			
			<sch:assert test="descendant::asset[not(asset)]/@init">Missing init attribute.  Check that all assets with no descendant assets, in the <sch:value-of select="$name" /> collection have an init attribute.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Tickets</sch:title>
		
		<sch:rule context="/game/tickets/ticket">
			
			<sch:assert test="self::ticket[@points or (country|location)/@points]">Missing points.  Every ticket must have a points value.  Add a points attribute to either the ticket element or a child destination (country|location) element.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
	
		<sch:title>Locations</sch:title>
		
		<sch:rule context="location[ancestor::locations/parent::map]">
			
			<sch:assert test="self::location[@id = ancestor::map/routes/route/location/@ref]">Unused Location: <sch:value-of select="if (name) then concat(name, ' (', @id, ')') else @id" />. Every location must be linked to at least one other by a route.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
	
	<sch:pattern>
		
		<sch:title>Routes</sch:title>
		
		<sch:rule context="/game/map/routes/route">
			
			<sch:assert test="self::route[@colour or colour/@ref]">Missing colour. Every route must have a colour.  Add a colour attribute if the route is single, or colour elements if the route is double or greater (one per route option).</sch:assert>
			
		</sch:rule>
		
		<sch:rule context="/game/map/routes/route/location">
			
			<sch:assert test="self::location[@ref = ancestor::map/locations/descendant::location/@id]">Invalid location ID: <sch:value-of select="@ref" />. Every route location reference must use an ID defined in map/locations.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
		
	<sch:pattern>
		
		<sch:title>Shortest Paths</sch:title>
		
		<sch:rule context="/game/map/shortest-paths/path/location">
			
			<sch:assert test="self::location[@ref = ancestor::map/locations/descendant::location/@id]">Invalid location ID: <sch:value-of select="@ref" />. Every shortest-path location reference must use an ID defined in map/locations.</sch:assert>
			
		</sch:rule>
		
	</sch:pattern>
	
</sch:schema>