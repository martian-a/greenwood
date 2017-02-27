xquery version "3.0";

(: Import application function library. :)
import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";


(: Split the request URL into its component parts :)
let $params := tokenize(substring-after($exist:path, '/'), '/')

return

	(: Check that the request is for a supported:
		- format (html|xml)
		- entity (game|location)
	:)
	if ($params[1] = ('html', 'xml') and $params[2] = ('game', 'location'))
	
	(: Supported request :)
	then (
	
		(: Retrieve any specifically requested entities :)
		let $matches :=
		
			if ($params[3])
			
			(: Specific entity requested :)
			then (
			
				if ($params[2] = 'location')
			
				(: Location entity requested. Retrieve all matches in the data. :)
				then (
					let $location-tokens := tokenize($params[3], '-')
					for $location in $loc:db/game[@id = $location-tokens[1]]/map/locations/descendant::*[@id = $location-tokens[2]]
					return $location
				)
				
				(: Game entity requested. Retrieve all matches in the data. :)
				else (
					let $game-tokens := tokenize($params[3], '-')
					for $game in $loc:db/game[@id = $game-tokens[1]]
					return $game
				)
			)
			
			(: No specific entity requested.  Matches = 0 :)
			else ()
			
		return
			
			(: Check whether a specific entity has been requested and found :)
			if (count($matches) = 1)
			
			(: Specific entity requested and found
				Respond with corresponding XML or HTML document.
			:)
			then (
				<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			        <forward url="{$exist:controller}/{$params[1]}/{$params[2]}.{$params[1]}">
			            <add-parameter name="id" value="{upper-case($params[3])}"/>
			        </forward>
			    </dispatch>
			)
			
			(: Either:
				- no specific entity requested; or
				- a specific entity was requested but not found
				
				Respond with index for entity type requested.
			:)
			else (
				<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			        <forward url="{$exist:controller}/html/{$params[2]}.html" />
			    </dispatch>
			)
	
	)
	
	(: Unsupported request.  Redirect to the games HTML index. :)
	else (
		<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
	        <forward url="{$exist:controller}/html/game.html" />
	    </dispatch>
	)