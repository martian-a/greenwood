xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
import module namespace local = "http://ns.greenwood.thecodeyard.co.uk/settings/local" at "/db/apps/greenwood/modules/local.xq";

declare option exist:serialize "method=xml media-type=text/xml indent=yes";

<results>{
    let $collection := $loc:upload-path-to-js
    let $directory := $local:path-to-js
    let $pattern := "*.js"
    
    (: TODO: Correct mime type once exist-db updated to support it :)
    let $mime-type := "application/x-javascript"
    return 
        <request>
            <collection>{$collection}</collection>
            <directory>{$directory}</directory>
            <pattern>{$pattern}</pattern>
            <mime-type>{$mime-type}</mime-type>
            <uploaded>{
                for $file in xmldb:store-files-from-pattern(
                    $collection, 
                    $directory, 
                    $pattern, 
                    $mime-type
                )
                return
                    <file>{$file}</file>
            }</uploaded>
     </request>
}</results>
    