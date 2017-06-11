xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
import module namespace local = "http://ns.greenwood.thecodeyard.co.uk/settings/local" at "/db/apps/greenwood/modules/local.xq";

declare option exist:serialize "method=xml media-type=text/xml indent=yes";

let $target-collection := $loc:upload-path-to-data
let $source-directory := $local:path-to-data
let $pattern := "*.xml"
let $mime-type := "text/xml"
let $preserve-structure := false()
return 
	<results>{
	        <request>
	            <collection>{$target-collection}</collection>
	            <directory>{$source-directory}</directory>
	            <pattern>{$pattern}</pattern>
	            <mime-type>{$mime-type}</mime-type>
	            <uploaded>{
	                for $file in xmldb:store-files-from-pattern(
	                    $target-collection, 
	                    $source-directory, 
	                    $pattern, 
	                    $mime-type,
	                    $preserve-structure
	                )
	                return
	                    <file>{$file}</file>
	            }</uploaded>
	     </request>
	}</results>
	    