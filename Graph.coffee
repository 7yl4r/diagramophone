class Graph
    ###
    A data class representing a directed graph.
    example object:
    ```js
    {
        "node_count": 2,
        "nodes":{
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
        }
    }
    ```
    ###

    constructor: ->
        @node_count = 0
        @root_node = {children:[]}  # imaginary common ancestor node, use to traverse all recursively
        @nodes = {}
        @trash_bin = {}  # removed nodes go here in case we want them back later

    add_node: (name, parents=[], children=[], others={}) ->
        ###
        adds a node to the model. returns node if added.
        :param others: an object with additional key-value pairs to be added to the node
        :Returns: node object which has been added
        ###
        throw Error('node name needed!') unless name
        try
            existing_node = @get_node(name)
            throw Error('node already exists!')
        catch err
            if err.message.split(':')[0] == "node not found"
                try 
                    return @_unrecycle_node(name)
                catch err
                    if err.message == "node not in trash bin"
                        new_node = {"name":name, "parents": parents, "children": children}
                        if others
                            new_node[attribute] = others[attribute] for attribute of others
                        @nodes[name] = new_node
                        @node_count += 1
                        @_parent_check(@nodes[name])
                        return @nodes[name]
                    else
                        throw err

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
            node = @add_node(name, parents ? [], children ? [])

        @_parent_check(node)
        return node

    rename_node: (old_name, new_name) ->
        @nodes[new_name] = @get_node(old_name)
        @nodes[new_name].name = new_name
        delete @nodes[old_name]

    add_edge: (from_node, to_node) ->
        ### adds a connection between two nodes given by id strings. returns true if success ###
        fn = @get_node(from_node)
        tn = @get_node(to_node)

        if fn and tn
            # connect if not already connected
            if to_node not in fn.children
                fn.children.push(to_node)
            if from_node not in tn.parents
                tn.parents.push(from_node)

            if to_node in @root_node.children  # if orphan is gaining a parent
                # unroot it
                @_unroot(tn)

            return true
        else
            throw Error("cannot add edge, invalid nodes:" + from_node + "=" + fn + ", " + to_node + "=" + tn)

    get_parents_of: (node_id) ->
        ###
        _Returns:_ list of parents of given node or empty array if None
        ###
        return @get_node(node_id).parents

    get_node: (id, chill=false) ->
        ###
        _Returns:_ the node object.
        _param chill:_ if true: returns undefined when not found, if false: freaks out and throws an error
        ###
        node = @nodes[id]
        if node
            return node
        else
            if chill
                return undefined
            else
                throw Error("node not found")
                
    clear: () -> 
        ###
        clears all edges from nodes and recycles all nodes
        ###
        # put all (de-edged) nodes in trash_bin
        for nodeId of @nodes
            @trash_bin[nodeId] = @_recycle_node(nodeId)
            
        # remove all nodes from list
        @nodes = {}
        @node_count = 0
        @root_node.children = []
        
    _unrecycle_node: (nodeId) ->
        node = @trash_bin[nodeId]
        if node
            @nodes[nodeId] = node
            @node_count += 1
            @_parent_check(node)
            return node
        else
            throw Error("node not in trash bin")
        
    _recycle_node: (nodeId) ->
        ###
        prepares node for trash_bin by removing edges
        :returns: recycled node object
        ###
        nodeObj = @nodes[nodeId]
        delete nodeObj.arrow
        delete nodeObj.colour
        delete nodeObj.drawn
        delete nodeObj.top
        nodeObj.parents = []
        nodeObj.children = []
        return nodeObj

    _parent_check: (node) ->
        ### adds given node to root node if (s)he is a poor little orphan node ###
        if node.parents.length == 0
            @root_node.children.push(node.name)

    _has_root_link: (node, callChain=[]) ->
        ### returns true if given node has ancestor that links to root, else returns false ###
        if node.name in @root_node.children  # if root my daddy
            return true
        else if node.parents.length == 0  # if I am orphan
            return false
        else
            if node.name in callChain  # if we've made a loop
                return false
            else
                callChain.push(node.name)
                for parentId in node.parents
                    if @_has_root_link(@get_node(parentId), callChain)
                        return true  # root is be my daddy's daddy's daddy's daddy's...
                return false  # i can't link back to root

    _unroot: (node) ->
        ### removes node from root, but ensures that root remains an ancestor to the cluster ###
        @root_node.children.splice(@root_node.children.indexOf(node.name), 1)
        if !@_has_root_link(node)
            # oops, put it back.
            @root_node.children.push(node.name)
            return false
        else
            return true



try  # use as global class if client
    window.Graph = Graph
catch error  # export if node.js
    module.exports = Graph
