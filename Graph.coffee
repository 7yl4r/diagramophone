class Graph
    ###
    A data class representing a directed graph.
    example object:
    ```js
    {
        "node_count": 2,
        "nodes":[
            {
                "name":"node1",
                "parents": [],
                "children": [
                    "node2"
                ]
            },{
                "name":"node2",
                "parents": [
                    "node1"
                ],
                "children": []
            }
        ]
    }
    ```
    ###
    
    constructor: ->
        @node_count = 0
        @nodes = []

    add_node: (name, parents=[], children=[], others={}) ->
        ###
        adds a node to the model. returns node if added, undefined if node already exists.
        :param others: an object with additional key-value pairs to be added to the node
        ###
        if @get_node(name) == undefined
            new_node = {
                "name":name,
                "parents": parents,
                "children": children}
            for attribute of others
                new_node.attribute = others.attribute
            @nodes.push(new_node)
            @node_count += 1
            return new_node
        else
            return undefined

    update_node: (name, parents, children) ->
        ###
        updates the given node. undefined should be passed for any items that should remain unchanged
          Example usage: @update_node('my_node_name', undefined, ['node_b', 'node_c'])
          updates only the parents of the 'my_node_name' node.
        If node is not found, it is added.
        ###
        node = @get_node(name)
        if node
            node.parents = parents ? node.parents
            node.children = children ? node.children
        else
            # add node
            @add_node(name, parents ? [], children ? [])

    rename_node: (old_name, new_name) ->
        return @get_node(old_name).name = new_name

    add_edge: (from_node, to_node) ->
        fn = @get_node(from_node)
        tn = @get_node(to_node)
        if to_node not in fn.children
            fn.children.push(to_node)
        if from_node not in tn.parents
            tn.parents.push(from_node)

    get_parents_of: (node_id) ->
        ###
        _Returns:_ list of parents of given node or empty array if None
        ###
        return @get_node(node_id).parents

    get_node: (id) ->
        ###
        _Returns:_ the node object.
        ###
        for node in @nodes
            if node.name == id
                return node
        return undefined

try  # use as global class if client
    window.Graph = Graph
catch error  # export if node.js
    module.exports = Graph
