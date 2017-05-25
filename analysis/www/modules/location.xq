xquery version "3.0";

module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location";
import module namespace cred = "http://ns.greenwood.thecodeyard.co.uk/credentials" at "/db/apps/greenwood/modules/cred.xq";

declare namespace test="http://exist-db.org/xquery/xqsuite";
declare namespace httpclient="http://exist-db.org/xquery/httpclient";

declare variable $loc:db := collection("/db/apps/greenwood/data");
declare variable $loc:host := "http://localhost:8080";

declare variable $loc:path-to-view := "/exist/rest/db/apps/greenwood/view/";
declare variable $loc:path-to-view-xml := concat($loc:path-to-view, "xml/");
declare variable $loc:upload-path-to-data := "/db/apps/greenwood/data/";
declare variable $loc:upload-path-to-view := "/db/apps/greenwood/view/";
declare variable $loc:upload-path-to-css := "/db/apps/greenwood/style/";
declare variable $loc:upload-path-to-xslt := "/db/apps/greenwood/xslt/";
declare variable $loc:upload-path-to-js := "/db/apps/greenwood/js/";


declare 
    %test:args('SWI-GEN')
    %test:assertEquals('<location id="GEN"><name>Geneve</name><games><game id="SWI"><title>Schweiz</title></game></games></location>')
function loc:get-location($id as xs:string) as item()? {
    loc:get-location($id, false(), false())
};


declare 
    %test:args('SWI-GEN', 'false')
    %test:assertEquals('<location id="GEN"><name>Geneve</name><games><game id="SWI"><title>Schweiz</title></game></games></location>')
function loc:get-location($id as xs:string, $with-connections as xs:boolean) as item()? {
    loc:get-location($id, $with-connections, false())
};

declare function loc:get-location($id as xs:string, $with-connections as xs:boolean, $with-paths as xs:boolean) as item()? {
    loc:get-location($id, $with-connections, false(), false())
};

declare 
    %test:args('SWI-GEN', 'true', 'false')
    %test:assertEquals('<location id="GEN"><name>Geneve</name><games><game id="SWI"><title>Schweiz</title></game></games><connections><location id="FRA3" length="1" tunnel="false" ferry="0" microlight="false"><name><name>France (FRA3)</name></name><colour><name>Yellow</name></colour></location><location id="LAU" length="4" tunnel="false" ferry="0" microlight="false"><name><name>Lausanne</name></name><colour><name>Blue</name></colour><colour><name>White</name></colour></location><location id="YVE" length="6" tunnel="false" ferry="0" microlight="false"><name><name>Yverdon</name></name><colour><name>Grey</name></colour></location></connections></location>')
function loc:get-location($id as xs:string, $with-connections as xs:boolean, $with-paths as xs:boolean, $with-sub-locations as xs:boolean) as item()? {
    
    let $game-id := substring-before($id, '-')
    let $location-id := substring-after($id, '-')
    
    let $locations := $loc:db/game[@id = $game-id]/map/locations//(country|location)[@id]
    for $location in $locations[@id = $location-id]
    let $games := 
        <games>
            {
                for $game in $location/ancestor::game
                return
                    <game id="{string($game/@id)}">{$game/title}</game>
            }
        </games>
    let $connections := 
        if ($with-connections)
        then loc:get-connections($id)
        else ()
    let $paths :=
        if ($with-paths)
        then loc:get-shortest-paths($id)
        else ()
    let $sub-locations :=
    	if ($with-sub-locations)
    	then loc:get-sub-locations($id)
    	else ()
    return
        <location id="{$location/@id}">
            {
                if ($location/name) 
                then $location/name
                else (
                	for $ancestor in $location/ancestor::*[name][1]
                	let $name := concat($location/ancestor::country[1]/name, ' (', $location/@id, ')')
                	return
                		if ($ancestor/name/@sort)
                		then 
                			<name sort="{concat($ancestor/name/@sort, ' (', $location/@id, ')')}">{$name}</name>
                		else
                			<name>{$name}</name>
                    
                )
            }
            {
                $games,
                if ($connections/*) 
                then $connections
                else (),
                if ($paths/*)
                then $paths
                else (),
                if ($sub-locations/*)
                then $sub-locations
                else ()
            }
        </location>
};

declare 
    %test:args('SWI-GEN')
    %test:assertEquals('<connections><location id="FRA3" length="1" tunnel="false" ferry="0" microlight="false"><name><name>France (FRA3)</name></name><colour><name>Yellow</name></colour></location><location id="LAU" length="4" tunnel="false" ferry="0" microlight="false"><name><name>Lausanne</name></name><colour><name>Blue</name></colour><colour><name>White</name></colour></location><location id="YVE" length="6" tunnel="false" ferry="0" microlight="false"><name><name>Yverdon</name></name><colour><name>Grey</name></colour></location></connections>')
function loc:get-connections($id as xs:string) as item() {
    
    let $game-id := substring-before($id, '-')
    let $location-id := substring-after($id, '-')
    
    let $routes := $loc:db/game[@id = $game-id]/map/routes/route
    return
        <connections>{
            for $route in $routes[location/@ref = $location-id]
            let $colours := $route/ancestor::map[1]/colours
            let $terminus-id := concat($game-id, '-', string($route/location/@ref[. != $location-id]))
            let $location := loc:get-location($terminus-id)
            return
                <location id="{$location/@id}" length="{$route/@length}" tunnel="{$route/@tunnel/xs:boolean(.)}" ferry="{if ($route/@ferry > 0) then ($route/@ferry) else 0}" microlight="{$route/@microlight/xs:boolean(.)}">
		           	{
		           		$location/name,
                        for $colour-id in $route/(@colour | colour/@ref)
                        let $colour := $colours/colour[@id = $colour-id]/name
                        return
                            <colour>{$colour}</colour>
                    }
                </location>
        }</connections>
    
};

declare function loc:get-shortest-paths($id as xs:string) as item() {
    
    let $game-id := substring-before($id, '-')
    let $location-id := substring-after($id, '-')
    return
        <shortest-paths>{
            for $path in $loc:db/game[@id = $game-id]/map/shortest-paths/path[location/@ref = $location-id]
            let $distance := $path/@distance
            let $terminus-id := concat($game-id, '-', $path/location[@ref != $location-id]/@ref)
            let $location := loc:get-location($terminus-id)
            return
                <location id="{$location/@id}" distance="{$distance}">
                    {
	                    $location/name,
    	                $path/via
    	             }
                </location>
        }</shortest-paths>
    
};

declare function loc:get-sub-locations($id as xs:string) as item() {
    
    let $game-id := substring-before($id, '-')
    let $location-id := substring-after($id, '-')
    return
        <sub-locations>{
            for $sub-location in $loc:db/game[@id = $game-id]/map/locations//*[@id = $location-id]/descendant::*[@id] 
            let $sub-location-id := concat($game-id, '-', $sub-location/@id)
            return loc:get-location($sub-location-id)
        }</sub-locations>
    
};

declare function loc:get-game($id as xs:string) as item() { 
   $loc:db/game[@id = $id]
};


declare function loc:request-http($uri as xs:anyURI) as item() {
  let $credentials := concat($cred:username,":",$cred:password)
  let $credentials := util:string-to-binary($credentials)
  let $headers  := 
    <headers>
      <header name="Authorization" value="Basic {$credentials}"/>
    </headers>
  return httpclient:get(xs:anyURI($uri),false(), $headers)
};

declare function loc:request-xml($path as xs:string) as item()* {
    let $uri := xs:anyURI(concat($loc:host, $loc:path-to-view-xml, $path))
    let $response := loc:request-http($uri)
    return $response/httpclient:body/*
};