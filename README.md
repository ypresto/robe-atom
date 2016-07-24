# Robe for Atom

Unofficial implementation of [Robe](https://github.com/dgutov/robe) client for Atom.

# Installation

Install [autocomplete-plus](https://github.com/atom/autocomplete-plus) and robe plugins in Atom's prefernces.
Then clone robe (server) repo to `~/github/robe`.

```
mkdir -p ~/github
git clone https://github.com/dgutov/robe ~/github/robe
```

Please note that robe server requires pry to be installed (with bundler).

# Limitations

* Currently only first project path is used.
* Fuzzy completion is not supported.

# License

The MIT License
