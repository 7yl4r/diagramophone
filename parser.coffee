class window.Parser
	constructor: ->
		@topLevelNode = ''
		
	parse: (text) ->
		allTheLines = text.split("\n")
		parsedBits = []

		# <3 coffescript
		parsedBits.push(@parseLine line) for line in allTheLines
		return @parseTree parsedBits

	parseTree: (parsedBits) ->
		### converts parsed bits into a Graph object ###
		graph = new Graph
		
		for bit in parsedBits
			continue unless bit
			aname = bit.first.name
			bname = bit.second.name

			a = graph.get_node(aname)
			b = graph.get_node(bname)
			
			graph.add_node(aname, [], [bname], {colour: ""}) if !a 
			graph.add_node(bname, [aname], [], {colour: ""}) if !b

			# don't panic about self loops
			continue if aname == bname

			# if the colours or arrow have updated, save them
			a.colour = bit.first.colour if a && bit.first.colour
				
			if b
				b.colour = bit.second.colour if bit.second.colour
				b.arrow = bit.arrow if bit.arrow

		return graph
			
	isFirstLevelNode: (node, graph) ->
		### returns true if given node has no parents in given graph ###
		if @topLevelNode != ''
			for node in graph.nodes
				if node and node.parents.length == 0
					@topLevelNode = node.name
					return true 
		
		return false

	parseLine: (text) ->
		return unless text # hey there paranoia
		parsedBit = {}
		parsedBit.first = {name: "", colour: ""}
		parsedBit.second = {name: "", colour: ""}
		parsedBit.arrow = {message:"", type: "", headLeft:"", headRight: ""}

		# parse the message
		line = text
		if @hasMessage text
			lineAndMsg = @extractLineAndMessage text
			line = lineAndMsg.line
			parsedBit.arrow.message = lineAndMsg.message

		return unless line

		return if @hasComment line
		
		# parse the names
		namesAndArrow = @extractNamesAndArrow line
		
		# if this is null, we have a standalone block
		if !namesAndArrow
			parsedBit.first.name = line
		else		
			parsedBit.first.name = namesAndArrow.names.first
			parsedBit.second.name = namesAndArrow.names.second
			parsedBit.arrow.type = namesAndArrow.arrow.type
			parsedBit.arrow.headLeft = namesAndArrow.arrow.headLeft
			parsedBit.arrow.headRight = namesAndArrow.arrow.headRight
			parsedBit.arrow.direction = namesAndArrow.arrow.direction

		# parse the colours	
		if @hasColour parsedBit.first.name
			namesAndCol = @extractNameAndColour parsedBit.first.name
			parsedBit.first.name = namesAndCol.name
			parsedBit.first.colour = namesAndCol.colour
		if @hasColour parsedBit.second.name
			namesAndCol = @extractNameAndColour parsedBit.second.name
			parsedBit.second.name = namesAndCol.name
			parsedBit.second.colour = namesAndCol.colour

		return parsedBit

	hasMessage: (text) ->
		return text.indexOf(":") != -1

	hasColour: (text) ->
		return text.indexOf("{") != -1 && text.indexOf("}") != -1

	hasComment: (text) ->
		return text.indexOf("//") != -1

	extractLineAndMessage: (text) ->
		# first -> second : message
		lineWithMessage = ///(.*):(.*)///
		[line, message] = text.match(lineWithMessage)[1..2]
		return {line:line.trim(), message:message.trim()}

	extractNameAndColour: (text) ->
		# name {colour}
		nameAndColour = ///(.*){(.*)}///
		[name, colour] = text.match(nameAndColour)[1..2]
		return {name:name.trim(), colour:colour.trim()}

	extractNamesAndArrow: (text) ->
		doubleArrow = ///(.*)(<>-<>|<->|<-<>|<>->|<>\.\.<>|<\.\.>|<\.\.<>|<>\.\.>)(.*)///
		singleArrow = ///(.*)(->|\.\.>|-<>|\.\.<>|<-|<\.\.|<>-|<>\.\.)(.*)///
		noArrow = ///(.*)(--|\.\.|-\.-)(.*)///
		# first try to match the double arrow. if that works, then you've hit jackpot
		# if that doesn't match, then go for the single arrow
		# if i join these in one massive regexp, sanity breaks and i'm not debugging regexps.		
		try 
			[first, arrow, second] = text.match(doubleArrow)[1..3]
		catch e1
			# didn't match a double arrow. can we match a single arrow?
			try
				[first, arrow, second] = text.match(singleArrow)[1..3]
			catch e2
				# didn't match a single arrow. no arrows at all?
				try
					[first, arrow, second] = text.match(noArrow)[1..3]
				catch e3
					return null
		
		return {names:{first:first.trim(), second:second.trim()}, arrow:@extractArrow(arrow)}
	
	# TODO: this is still gross
	extractArrow: (text) ->
		# arrow head. this is gross
		if text[0] == "<" && text[1] == ">"
			headLeft = "diamond"
		else if text[0] == "<"
			headLeft = "classic"
		else
			headLeft = "none"
		
		if text[text.length-2] == "<" && text[text.length-1] == ">"
			headRight = "diamond"
		else if text[text.length-1] == ">"
			headRight = "classic"
		else
			headRight = "none"			
	
		# dash type
		if text.indexOf("..") != -1
			type = "-"
		else if text.indexOf("-.-") != -1 
			type = "-"
		else 
			type = ""
		
		# direction: left, right, both
		# here we're assuming that botht he diamond and the arrow end in a >
		if text[0] == "<" and text[text.length-1] == ">"
			direction = "both"
		else if text[0] == "<"
			direction = "left"
		else if text[text.length-1] == ">"
			direction = "right"
		else
			direction = ""
			
		return {direction: direction, type:type, headLeft:headLeft, headRight:headRight}