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
        adds a node to the model. returns node if added or existing node if already exists.
        :param others: an object with additional key-value pairs to be added to the node
        ###
        try
            existing_node = @get_node(name)
            return existing_node
        catch err
            if err.message == 'node not found:"+name
                new_node = {
                    "name":name,
                    "parents": parents,
                    "children": children}
                for attribute of others
                    new_node.attribute = others.attribute
                @nodes.push(new_node)
                @node_count += 1
                return new_node

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
        # get node objects if name strings are given
        if from_node.name  # if node object given, use it
            fn = from_node
        else  # must be node name
            fn = @get_node(from_node)

        if to_node.name
            tn = to_node
        else
            tn = @get_node(to_node)

        if fn and tn
            # connect if not already connected
            if to_node not in fn.children
                fn.children.push(to_node)
            if from_node not in tn.parents
                tn.parents.push(from_node)
        else
            throw Error("cannot add edge, invalid nodes:" + from_node + '=' + fn + ', ' + to_node + '=' + tn)

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

        throw Error("node not found:" + id)

try  # use as global class if client
    window.Graph = Graph
catch error  # export if node.js
    module.exports = Graph
