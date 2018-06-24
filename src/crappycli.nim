from strutils import strip, startsWith, isNilOrEmpty
from tables import initTable, Table, hasKey, `[]`, add, len
from sequtils import filter


type
  CrappyCli* = ref object
    positionals: seq[string]
    switches: Table[string, string]


#---- Internal Helpers ----#


proc isSwitch (value: string): bool {.inline, noSideEffect.} =
  result = value.strip.startsWith "-"


proc removeSwitchToken (value: string): string {.noSideEffect.} =
  if value.isSwitch:
    if value.startsWith "--":
      return value[2..high(value)]
    if value.startsWith "-":
      return value[1..high(value)]
  result = value


#---- Positional Sugar ----#


proc positionalCount* (crappy: CrappyCli): int {.noSideEffect.} =
  ## The number of positionals used.
  result = crappy.positionals.len


proc nth* (crappy: CrappyCli, position: int): string {.noSideEffect.} =
  ## Gets the nth positional argument or "".
  if position > 0 and
     crappy.positionals.len >= position and
     not crappy.positionals[position - 1].isNil:
    result = crappy.positionals[position - 1]
  else:
    result = ""


proc first* (crappy: CrappyCli): string {.noSideEffect.} =
  ## Grabs the 1st positional argument or "".
  result = crappy.nth(1)


proc second* (crappy: CrappyCli): string {.noSideEffect.} =
  ## Grabs the 2nd positional argument or "".
  result = crappy.nth(2)


proc third* (crappy: CrappyCli): string {.noSideEffect.} =
  ## Grabs the 3rd positional argument or "".
  result = crappy.nth(3)


proc last* (crappy: CrappyCli): string {.noSideEffect.} =
  ## Grabs the last positional argument or "".
  result = crappy.nth(crappy.positionals.len)


#---- Switch Sugar ----#


proc switchCount* (crappy: CrappyCli): int {.noSideEffect.} =
  ## Counts the number of switches.
  result = crappy.switches.len


proc has* (crappy: CrappyCli, name: string): bool {.noSideEffect.} =
  ## Do we have a switch with the given name?
  result = crappy.switches.hasKey(name)


proc `[]`* (crappy: CrappyCli, name: string): string {.noSideEffect.} =
  ## Gets the value of a switch or "".
  if crappy.switches.hasKey(name) and not crappy.switches[name].isNil:
    result = crappy.switches[name]
  else:
    result = ""


proc empty* (crappy: CrappyCli): bool {.noSideEffect.} =
  ## Checks if anything at all was passed as a switch or positional.
  result = crappy.switches.len == 0 and crappy.positionals.len == 0


#---- Initialization ----#


proc newCrappyCli* (params: seq[string], flags: seq[string] = @[]): CrappyCli =
  ## Normalizes and organizes the command line arguments.
  new(result)

  result.positionals = @[]
  result.switches = initTable[string, string]()

  var skipNext = false
  var i = 0

  # strip any empty strings
  let filteredParams = params.filter(proc (x: string): bool = not x.isNilOrEmpty)

  for arg in filteredParams:
    # should we skip this param (cuz its the value of a switch?)
    if skipNext:
      skipNext = false
    else:
      # clean up the inbound argument
      let arg = arg.strip
      let argName = arg.removeSwitchToken

      if arg.isSwitch:
        # prepare the value
        var value = ""

        # peek at next argument
        if not flags.contains(argName):
          if i + 1 < filteredParams.len:
            if not filteredParams[i + 1].isSwitch:
              value = filteredParams[i + 1].strip
              skipNext = true

        # this is a switch
        result.switches.add argName, value
      elif arg.len > 0:
        # this is a positional
        result.positionals.add arg
    i += 1
