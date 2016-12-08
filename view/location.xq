xquery version "3.0";

declare namespace request="http://exist-db.org/xquery/request";

import module namespace loc = "http://ns.greenwood.thecodeyard.co.uk/location" at "/db/apps/greenwood/modules/location.xq";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";

let $data := collection("/db/apps/greenwood/data")
let $request-id := string(request:get-parameter("id", ""))

return
    if ($request-id != "")
    then
        let $location := loc:get-location($request-id)
        let $connections := loc:get-connections($location/@id)
        return
            <html>
                <head>
                    <title>{string($location/name)}</title>    
                </head>
            	<body>
            	    <p><a href="location.xq">Locations</a></p>
            	    <h1>{string($location/name)}</h1>
            	     <div>
            	       <h2>Connections ({count($connections)})</h2>
            	       <table>
            	           <tr>
                                <th>Location</th>
                                <th>Length</th>
                                <th>Double</th>
                                <th>Colour</th>
                                <th>Tunnel</th>
            	           </tr>
            	           {
                	         for $connection in $connections
                	         order by $connection/name ascending
                	         return
                	             <tr>
                    	            <td><a href="location.xq?id={string($connection/@id)}">{string($connection/name)}</a></td>
                    	            <td>{string($connection/@length)}</td>
                    	            <td>{string(boolean(count($connection/colour) gt 1))}</td>
                    	            <td>{string-join($connection/colour, ", ")}</td>
                    	            <td>{string($connection/@tunnel)}</td>
                	            </tr>
            	           }
            	       </table>
            	     </div>
            	 </body>
             </html>
    else 
            <html>
                <head>
                    <title>Locations</title>    
                </head>
            	<body>
            	    <h1>Locations</h1>
            	    <ul>
                	 {
                	   for $location-id in $data/game/map/locations/country/location/@id
                	   let $location := loc:get-location($location-id)
                	   order by $location/name ascending
                	   return
                	    <li><a href="location.xq?id={string($location/@id)}">{string($location/name)}</a></li>
                	 }
                	</ul> 
            	 </body>
             </html>