# crappycli 💩

A crappy [`nim`](https://nim-lang.org) library for parsing command line arguments.

> I'm new at `nim` and am extracting this from one of my projects to get used to writing packages.

# Installing

`nimble install https://github.com/skellock/crappycli`

Or, hey, just copy the `crappycli.nim` file and paste it into your project. 💃

# Usage

```nim
import crappycli
from os import commandLineParams

# new crappy cli!
let cli = commandLineParams.newCrappyCli()

# check for flags
cli.has('force')

# read a switch
cli['output']

# read positional arguments
cli.first
cli.second
cli.third
cli.last
cli.nth(1)

# count some stuff
cli.switchCount
cli.positionalCount
cli.empty
```

# Alternate

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

# told ya it was crappy! 🎰
```

# License

MIT.  🤷‍♂️

# Contributing

😂

If you have any tips, I'm all ears!
