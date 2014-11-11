Alchemy::plugins.neo4jBackend = (instance) ->
  a: instance
  conf: instance.conf.plugins["neo4j"]
  graphJSON:  {}
  constructor: ->
    conf = @conf

    # Fill in blank settings with the defaults
    defaultSettings =
      "url"  : "http://127.0.0.1:7474/db/data/transaction/commit"
      "query": null

    @conf = _.defaults conf, defaultSettings

  runQuery: (query) ->
    plugin = @a.plugins.neo4jBackend
    conf   = @conf
    query  = if query? then query else conf.query

    # Send request to Neo4j
    d3.xhr(conf.url)
      .header "Content-Type", "application/json"
      .send "POST", JSON.stringify(
        statements: [{
          statement: query,
          parameters: {}
          resultDataContents:["row","graph"]
        }]
       ), (err, res)->
             return console.log(err) if err?
             res = JSON.parse res.response
             if res?
               cols = res.results[0].columns
               rows = res.results[0].data.map (r)->
                 results = {}
                 _.each cols, (col, index) ->
                   results[col] = r.row[index]
                 results
           
               nodes  = []
               edges  = []
               
               _.each res.results[0].data, (row)->
                 _.each row.graph.nodes, (n) ->
                   found = nodes.filter((m)-> m.id is n.id).length > 0
                   if not found
                     node = n.properties or {}
                     node.id = n.id
                     node.type = n.labels[0]
                     nodes.push(node)
                 edges = edges.concat row.graph.relationships.map (r)->
                   source : r.startNode
                   target : r.endNode
                   caption: r.type
             # return graph json
             plugin.graphJSON = nodes:nodes, edges:edges
