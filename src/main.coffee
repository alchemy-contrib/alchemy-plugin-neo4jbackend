Alchemy::plugins.neo4jBackend = (instance)->
  a: instance
  conf: instance.conf.plugins["neo4j"]
  constructor: ->
    conf = @conf
    console.log "It has loaded"

    # Fill in blank settings with the defaults
    defaultSettings =
      #"url": "http://127.0.0.1:7474/db/data",
      "url": "http://127.0.0.1:7474/db/data/transaction/commit"
      "template": null

    @conf = _.defaults conf, defaultSettings

  runTemplate: ->
    conf = @conf
    console.log "running template"
    
    d3.xhr(conf.url)
      .header "Content-Type", "application/json"
      #.header "Accept", "application/json"
      .send "POST", JSON.stringify(
        statements: [{
          statement: conf.template,
          parameters: {}
          resultDataContents:["row","graph"]
        }]
       ), (err, res)->
             console.log(err) if err?
             res = JSON.parse(res.response)
             if res?
               cols = res.results[0].columns
               rows = res.results[0].data.map (row)->
                 r = {}
                 _.each cols, (col, index) ->
                   r[col] = row.row[index]
                 r
           
               nodes  = []
               rels   = []
               labels = []
          
               console.log res
               _.each res.results[0].data, (row)->
                 _.each row.graph.nodes, (n) ->
                   found = nodes.filter((m)-> m.id is n.id).length > 0
                   if not found
                     node = n.properties or {}
                     node.id = n.id
                     node.type = n.labels[0]
                     nodes.push(node)
                     if labels.indexOf(node.type) is -1
                       labels.push node.type
                 rels = rels.concat row.graph.relationships.map (r)->
                  source: r.startNode
                  target: r.endNode
                  caption: r.type
              console.log null, {table:rows, graph:{nodes:nodes, edges:rels},labels:labels}
