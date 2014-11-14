(function() {
  Alchemy.prototype.plugins.neo4jBackend = function(instance) {
    return {
      a: instance,
      conf: instance.conf.plugins["neo4jBackend"],
      graphJSON: {},
      init: function() {
        var conf, defaultSettings;
        conf = this.conf;
        defaultSettings = {
          "url": "http://127.0.0.1:7474/db/data/transaction/commit",
          "query": null
        };
        return this.conf = _.defaults(conf, defaultSettings);
      },
      runQuery: function(query, callback) {
        var conf, plugin;
        plugin = this.a.plugins.neo4jBackend;
        conf = this.conf;
        query = query != null ? query : conf.query;
        return d3.xhr(conf.url).header("Content-Type", "application/json").send("POST", JSON.stringify({
          statements: [
            {
              statement: query,
              parameters: {},
              resultDataContents: ["row", "graph"]
            }
          ]
        }), function(err, res) {
          var cols, edges, nodes, rows;
          if (err != null) {
            return console.log(err);
          }
          res = JSON.parse(res.response);
          if (res != null) {
            cols = res.results[0].columns;
            rows = res.results[0].data.map(function(r) {
              var results;
              results = {};
              _.each(cols, function(col, index) {
                return results[col] = r.row[index];
              });
              return results;
            });
            nodes = [];
            edges = [];
            _.each(res.results[0].data, function(row) {
              _.each(row.graph.nodes, function(n) {
                var found, node;
                found = nodes.filter(function(m) {
                  return m.id === n.id;
                }).length > 0;
                if (!found) {
                  node = n.properties || {};
                  node.id = n.id;
                  node.type = n.labels[0];
                  return nodes.push(node);
                }
              });
              return edges = edges.concat(row.graph.relationships.map(function(r) {
                return {
                  source: r.startNode,
                  target: r.endNode,
                  caption: r.type
                };
              }));
            });
          }
          plugin.graphJSON = {
            nodes: nodes,
            edges: edges
          };
          if (callback != null) {
            callback(plugin.graphJSON);
          }
          return plugin.graphJSON;
        });
      }
    };
  };

}).call(this);
