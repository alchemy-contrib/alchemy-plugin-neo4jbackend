Alchemy::plugins.neo4jBackend = (instance) ->
  a: instance
  conf: instance.conf.plugins["neo4jBackend"]
  graphJSON:  {}
  init: ->
    conf = @conf
    instance.conf.backend = "neo4jBackend"

    # Fill in blank settings with the defaults
    defaultSettings =
      url  : "http://127.0.0.1:7474/db/data/transaction/commit"
      query:
        cypher  : "{0}"
        nodeType: "MATCH (n:{0}) RETURN n"
        edgeType: "MATCH ()-[e:{0}]->() RETURN e"
        nodeProp: "MATCH (n { {0}:'{1}' }) RETURN n"
        edgeProp: "MATCH ()-[e { {0}:'{1}' }]->() RETURN e"

    @conf = _.defaults conf, defaultSettings
  
  buildQuery: (input, type) ->
    
    # Allow 'printf' style formatting in strings
    String::format = (arr)->
      formatted = @
      _.each arr, (arg, i)->
        regex = new RegExp "\\{#{i}\\}", 'gi'
        formatted = formatted.replace regex, arg
      formatted

    inpArray = input.split /,\s*/
    if @conf.query[type]?
      return @conf.query[type].format inpArray
    return input

  runQuery: (query, callback=@updateGraph) ->
    plugin = @a.plugins.neo4jBackend
    conf   = @conf

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

             if callback? then callback(plugin.graphJSON, plugin.a)
             plugin.graphJSON

  updateGraph:(graphJSON, a) ->
    # Arguments can be blank if called directly.
    # If called as part of a callback arguments might be necessary
    a ?= instance
    graphJSON ?= @graphJSON

    a.create.nodes graphJSON["nodes"]
    a.create.edges graphJSON["edges"]
