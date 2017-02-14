# vim-sayid

This is currently a proof of concept in getting Vim to play nice with Bill
Piel's Sayid, a Clojure debugging tool. It effectively will retain historical
tracing data of your code so you can identify what problems, if any exist in
your code.

# Requirements

* [vim-fireplace](https://github.com/tpope/vim-fireplace)
* [Sayid](https://github.com/bpiel/sayid)

# Installation

`Plug 'arsenerei/vim-sayid`

# Basics

**NB: This is a proof of concept; expect things to change.**

Create a sample project and fire up a REPL. In your core.clj file, add the
following:

```clojure
(defn add [a b]
   (+ a b))
```

Trace this namespace:

`gst`

Execute this in the quasi-repl (via `cqp`):

`(add 1 1)`

Take a look at the Sayid workspace:

`gsw`

Get a deeper look at what `add` returned by placing your cursor over the add
line:

`gsq`

# TODO

* Have a persistent Sayid buffer
* Provide default mappings for basic functionality (e.g., enable/disable
  tracing, query, show-workspace)
* Syntax highlighting
