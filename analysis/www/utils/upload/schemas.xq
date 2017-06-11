xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
import module namespace local = "http://ns.greenwood.thecodeyard.co.uk/settings/local" at "/db/apps/greenwood/modules/local.xq";

declare option exist:serialize "method=xml media-type=text/xml indent=yes";

let $file-extension-list := "rnc sch"
let $target-collection := $loc:upload-path-to-schemas
let $source-directory := $local:path-to-schemas
let $preserve-structure := true()
return 
	<results>{
	        for $file-extension in tokenize($file-extension-list, ' ')
	        let $pattern := concat("**/*.", $file-extension)
            let $mime-type := 
                if ($file-extension = 'rnc') 
                then "text/plain"
                else "text/xml"
            return
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
	    