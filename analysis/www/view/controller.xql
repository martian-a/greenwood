xquery version "3.0";

declare variable $exist:path external;

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";


let $params := tokenize(substring-after($exist:path, '/'), '/')
return
	if ($params[1] = ('html', 'xml') and $params[2] = ('game', 'location'))
	then (
		let $matches :=
			if ($params[2] = 'location')
			then (
				let $location-tokens := tokenize($params[3], '-')
				for $location in $loc:db/game[@id = $location-tokens[1]]/map/locations/descendant::*[@id = $location-tokens[2]]
				return $location
			)
			else (
				let $game-tokens := tokenize($params[3], '-')
				for $game in $loc:db/game[@id = $game-tokens[1]]
				return $game
			)
		return
			
			if (count($matches) = 1)
			then (
				<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			        <forward url="{$exist:controller}/{$params[1]}/{$params[2]}.{$params[1]}">
			            <add-parameter name="id" value="{upper-case($params[3])}"/>
			        </forward>
			    </dispatch>
			)
			else (
				<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			        <forward url="{$exist:controller}/html/{$params[2]}.html" />
			    </dispatch>
			)
	
	)
	else (
		<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
	        <forward url="{$exist:controller}/html/game.html" />
	    </dispatch>
	)