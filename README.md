neo4jBackend
============

Neo4j backend for AlchemyJS

Plugin support is only for Alchemy 0.4.1 and higher.

neo4jBackend can be configured by placing a "plugins" key in the conf like so:

~~~ js
  var conf = {
    dataSource: "sample_data/movies.json",
    plugins: {
      neo4jBackend: {
        url  : "http://127.0.0.1:7474/db/data/transaction/commit",
        query: {
	  "cypher": "###",
	  "nodeType": "MATCH (n:###) RETURN n"
	}
      }
    }
  }
~~~

### Use:

Include the script and make sure `neo4jBackend : {}` is included in the `plugins` key of your alchemy configuration.

You can then build a cypher query by calling `alchemy.plugins.neo4jBackend.buildQuery(input, queryType)`, where queryType is the key of the query template to use that is defined in the `query` key of the configuration.  This will return a cypher statement which you can then pass in to `alchemy.plugins.neo4jBackend.runQuery(cypherStatement [, callback])`.  Passing in just a cypher statement and no callback will run your cypher query and update the alchemy graph with the results.  If you wish to modify or view the data before updating the graph, you can pass a callback in which will recieve the returned graphJSON for you to work with.  This stops automatic graphUpdating, so afterwards you will need to call `alchemy.plugins.neo4jBackend.updateGraph()`

After a query is ran, the latest results can be found in alchemy.plugins.neo4jBackend.graphJSON .

### Configuration:
The url to neo4j can be configured with the "url" key in the configuration.  If it is running locally, on the default port (7474) then you do not have to configure anything.  If you include a custom url, make sure it ends with the correct transaction endpoint 

~~~
  [neo4jURL]:[port]/db/data/transaction/commit
~~~

All queries have full access to both read and write capabilities...anything you can do from the neo4j console.
Use with caution and not in a world-facing production environment.

The `query` configuration can be set to create a custom cypher query. For example:

~~~ js 
  query: {
   ...
     "firstDegreeNodes": "MATCH (n)-->(m) WHERE n.id = '###' RETURN n, m",
   ...
  }
~~~

running `alchemy.plugins.neo4jBackend.buildQuery("33", "firstDegreeNodes")` will return
`MATCH (n)-->(m) WHERE n.id = '33' RETURN n, m`

Which, when passed into runQuery() will return graphJSON conaining all nodes directly connected to the node with an id of '33'.

### TODO:
* build out better API for neo4jBackend
* build out a "history" system, as well as saftey measures for possibly destructive cypher queries.
