# Robe for Atom

Unofficial implementation of [Robe](https://github.com/dgutov/robe) client for Atom.

# Usage

Currently this plugin does not have robe launcher at the moment.
Please run one of below snippet in your project root.

For rails:

```
ROBE_LIB_PATH=/path/to/robe/lib  bundle exec rails runner 'unless defined? Robe; $:.unshift ENV["ROBE_LIB_PATH"]; require "robe"; end; p Robe.start(24969); sleep 86400'
```

For bundler:

```
ROBE_LIB_PATH=/path/to/robe/lib  bundle exec ruby -e 'unless defined? Robe; $:.unshift ENV["ROBE_LIB_PATH"]; require "robe"; end; p Robe.start(24969); sleep 86400'
```

These snippet came from robe.el and [inf-ruby.el](https://github.com/nonsequitur/inf-ruby/blob/55559dfaacf58dd26819fbb1ef16d406583ae024/inf-ruby.el#L631).
Please note that robe requires pry to be installed.

# License

The MIT License
