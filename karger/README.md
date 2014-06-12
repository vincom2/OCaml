Randomized min-cut
==================
An implementation (definitely poorly done, probably incorrect) of Karger's min-cut algorithm.<br/>
At present (and let's face it, most likely forever), it only returns the _number_ of edges in the min cut (w.h.p.).<br/>
Maybe some day, if I refactor it, I'll make it produce the cut too.<br/>
(and yes, this means the "output .dot file" feature is absolutely useless)

Dependencies
------------
Requires
* Jane Street Core
* ocamlgraph

I build it with `corebuild -package ocamlgraph karger.native`.