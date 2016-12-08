xquery version "3.0";

module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location";

declare function loc:get-location($id as xs:string) as item()? {
    
    let $locations := collection("/db/apps/greenwood/data")/game/map/locations/country/location
    for $location in $locations[@id = $id]
    return
        <location id="{$location/@id}">
            <name>{
                if ($location/name) 
                then
                    string($location/name)
                else 
                    concat($location/ancestor::country[1]/name, ' (', $location/@id, ')')
            }</name>
        </location>
};

declare function loc:get-connections($id as xs:string) as item()* {
    
    for $route in collection("/db/apps/greenwood/data")/game/map/routes/route[location/@ref = $id]
    let $terminus-id := $route/location/@ref[. != $id]
    let $location := loc:get-location($terminus-id)
    return
        <location id="{$location/@id}" length="{$route/@length}" tunnel="{boolean($route/@tunnel)}">
            <name>{$location/name}</name>
            {
                for $colour-id in $route/(@colour | colour/@ref)
                let $colour := $route/ancestor::map[1]/colours/colour[@id = $colour-id]/name
                return
                    <colour>{$colour}</colour>
            }
        </location>
    
};
