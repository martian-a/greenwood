xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
import module namespace local = "http://ns.greenwood.thecodeyard.co.uk/settings/local" at "/db/apps/greenwood/modules/local.xq";

declare option exist:serialize "method=xml media-type=text/xml indent=yes";

let $game-id := request:get-parameter('game', '')
let $update-as-json := request:get-parameter('json', '')
let $update-as-xml :=
	document {
		element {"update"}{
			for $element in tokenize(substring($update-as-json, 2, (string-length($update-as-json) -2)), '\},')
			let $node-id := replace(tokenize($element, ':\{')[1], '&quot;', '')
			let $coordinates := replace(tokenize($element, ':\{')[2], '}', '')
			let $x := tokenize(tokenize($coordinates, ',')[1], ':')[2]
			let $y := tokenize(tokenize($coordinates, ',')[2], ':')[2]
			return
				element {"node"}{
					attribute {"ref"}{$node-id},
					attribute {"x"}{$x},
					attribute {"y"}{$y}
				}
		}
	}

let $game := collection("/db/apps/greenwood/data")/game[@id = $game-id]
let $results :=
	for $location in $game/map/locations/descendant::*[@id = $update-as-xml//node/xs:string(@ref)]
	let $node := $update-as-xml//node[@ref = $location/xs:string(@id)]
	return 
		(
			update insert attribute x {$node/@x} into $location,
			update insert attribute y {$node/@y} into $location
		)
return $game