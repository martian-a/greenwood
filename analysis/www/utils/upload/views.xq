xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
import module namespace local = "http://ns.greenwood.thecodeyard.co.uk/settings/local" at "/db/apps/greenwood/modules/local.xq";

declare option exist:serialize "method=xml media-type=text/xml indent=yes";

<results>{
    for $view in ('xml', 'html')
    let $collection := concat($loc:upload-path-to-view, $view)
    let $directory := concat($local:path-to-view, $view)
    let $pattern := concat("*.", $view)
    let $mime-type := "application/xquery"
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
    