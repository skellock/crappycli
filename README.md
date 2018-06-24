# crappycli 💩

A crappy [`nim`](https://nim-lang.org) package for parsing command line arguments.


### Warning

I'm new at `nim` and am extracting this from one of my projects to get used to writing packages.

You probably want to use one of the many other CLI argument parsing packages instead.  😃


# Installing

`nimble install https://github.com/skellock/crappycli`

Or, hey, just copy the `crappycli.nim` file and paste it into your project. 💃


# Usage

```nim
import crappycli
from os import commandLineParams

# new crappy cli!
let cli = newCrappyCli(commandLineParams())

# check for a switch that's just a flag
cli.has('force')

# read a switch that has a value
cli['output']

# read positional arguments
cli.first
cli.second
cli.third
cli.last
cli.nth(1) # reads the 1st positional argument (1-based 🤓)

# count some stuff
cli.switchCount
cli.positionalCount
cli.empty
```


### Ambiguous Switches

Sometimes your switches will be flags; meaning, they don't have a value associated with them.

By default, switches consume the next word after them... so, if you want to keep those as positional arguments, then you've gotta tell `CrappyCli` about your flags up front.  

Look, I told ya it was crappy! 🎰

```nim
# alternate way to create it by telling it switches
# which have no values
let cli = commandLineParams.newCrappyCli(@["verbose"])

# ^ used for corner cases where you have positionals
# right after switches, for example:
# 
#   mycli -v filename.json
#
# ^ in this case, we want the `-v` to be a flag and
# the `filename.json` to be a positional.
```


# License

MIT. 🤷


# Contributing

😂

If you have any tips, I'm all ears!
