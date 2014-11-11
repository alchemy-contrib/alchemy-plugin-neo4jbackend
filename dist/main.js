(function() {
  Alchemy.prototype.plugins.neo4jBackend = function(instance) {
    return {
      a: instance,
      conf: instance.conf.plugins["neo4j"],
      constructor: function() {
        var conf, defaultSettings;
        conf = this.conf;
        console.log("It has loaded");
        defaultSettings = {
          "url": "http://127.0.0.1:7474/db/data/transaction/commit",
          "template": null
        };
        return this.conf = _.defaults(conf, defaultSettings);
      },
      runTemplate: function() {
        var conf;
        conf = this.conf;
        console.log("running template");
        return d3.xhr(conf.url).header("Content-Type", "application/json").send("POST", JSON.stringify({
          statements: [
            {
              statement: conf.template,
              parameters: {},
              resultDataContents: ["row", "graph"]
            }
          ]
        }), function(err, res) {
          var cols, labels, nodes, rels, rows;
          if (err != null) {
            console.log(err);
          }
          res = JSON.parse(res.response);
          if (res != null) {
            cols = res.results[0].columns;
            rows = res.results[0].data.map(function(row) {
              var r;
              r = {};
              _.each(cols, function(col, index) {
                return r[col] = row.row[index];
              });
              return r;
            });
            nodes = [];
            rels = [];
            labels = [];
            console.log(res);
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
                  nodes.push(node);
                  if (labels.indexOf(node.type) === -1) {
                    return labels.push(node.type);
                  }
                }
              });
              return rels = rels.concat(row.graph.relationships.map(function(r) {
                return {
                  source: r.startNode,
                  target: r.endNode,
                  caption: r.type
                };
              }));
            });
          }
          return console.log(null, {
            table: rows,
            graph: {
              nodes: nodes,
              edges: rels
            },
            labels: labels
          });
        });
      }
    };
  };

}).call(this);
