# Diagramaphone

This is a little app that lets you write diagrams in a simple DSL, because I hate dragging and dropping things and hoping they snap-to-grid. Which they never do.

It's written in [CoffeeScript](http://jashkenas.github.com/coffee-script/), and uses [Raphael.js](http://raphaeljs.com/) to draw things. It uses other things too, including your kitchen sink.
It's not done yet, so some features will work like crazy monkeys.

## Things that work

#### Connecting blocks

You can connect blocks through lines (solid and dotted)
```
a -- b
a .. b
```

On which you can use connectors (arrows and diamonds)

```
a -> b
a ..> b
a <-b
a -<> b
a <>..b
```

Any line that starts with a // is considered a comment. What, you don't comment your diagrams? :)

#### Colours
Blocks can have colours: 

```
a -> b {red}
c{#ffb700} -> d
```
These colours can be either css colours names, or hex strings. If you have multiple statements applying different colours to the same block, last write wins.

#### Messages on arrows
You get one message per arrow, like so:
```
a -> b : o hai there arrow!
```

At the moment I'm not doing anything fancy about positioning this message, so it might overlap other arrows/messages/blocks

#### Predefining blocks
If you want, you can pre-define and style all your blocks at the beginning of the code, and then connect them afterwards, like so:

```
a {red}
b {yellow}
c
d
a -- b
a -> c
b <>-d
```

#### Attaching Events to the blocks
Events can be attached to blocks to make your diagrams more interactive. This is easily accomplished using jquery to get all elements in the "diagramophone-node-text" class:
```javascript
$(".diagramophone-node-text").on("click", function(evt){alert('node clicked: '+evt.target.innerHTML);});
```

## Things that don't work
(and that we call "open issues", are pretty annoying, and I'm working on fixing:)
* exporting the svg to a png loses the arrow heads and the dotted lines. yay :(
* the REPL gets very slow if you have a ton of blocks. This is because it's a dumb REPL, and on keyup redraws the entire diagram.


