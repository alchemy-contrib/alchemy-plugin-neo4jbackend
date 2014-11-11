neo4jBackend
============

Neo4j backend for AlchemyJS

Still dependant on Alchemy plugins being built in.
For it to work an empty "plugins" key should be added to the Alchemy prototype.

After that it can be configured by placing a "plugins" key in the conf like so:

~~~ js
  var conf = {
    dataSource: "sample_data/movies.json",
    plugins: {
      neo4j: {
        url  : "http://127.0.0.1:7474/db/data/transaction/commit",
        query: "MATCH (n) RETURN n"
      }
    }
  }
~~~

I've been running
~~~ js
var neo = alchemy.plugins.neo4jBackend; neo = alchemy.plugins.neo4jBackend = neo(alchemy); neo.constructor(); neo.runQuery()
~~~
in the console afterwards to initialize.  Again, this is something that will be taken care of by Alchemy after plugin support is built.

### USING:
While the "query" config setting defines a default query to execute, this isn't really reccommended and is mainly there for testing purposes or for very specific use cases.  Instead, a cypher query can be passed in to the runQuery() method:

~~~ js
  alchemy.plugins.neo4jBackend.runQuery("MATCH (n)-[e]->(m) RETURN n")
~~~

And those queries have full access to both read and write capabilities...anything you can do from the neo4j console.

Use with caution and not in a world-facing production environment.

After a query is ran, the latest results can be found in alchemy.plugins.neo4jBackend.graphJSON .

### TODO:
* build out plugin support in alchemy
* build out node creation API for alchemy
* build out better API for neo4jBackend
* build out a "history" system, as well as saftey measures for possibly destructive cypher queries.
