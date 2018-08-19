from strutils import strip, startsWith
from tables import initTable, Table, hasKey, `[]`, add, len
from sequtils import filterIt
from os import commandLineParams

type
    CrappyCli* = ref object
        positionals: seq[string]
        switches: Table[string, string]


proc isSwitch(value: string): bool {.inline, noSideEffect.} =
    # Does this string start with a dash?
    result = value.strip.startsWith "-"


proc removeSwitchToken(value: string): string {.noSideEffect.} =
    ## Removes upto 2 preceding dashes.
    result = value
    if value.startsWith "--":
        result = value[2..high(value)]
    elif value.startsWith "-":
        result = value[1..high(value)]


proc positionalCount*(crappy: CrappyCli): int {.noSideEffect.} =
    ## The number of positionals used.
    result = crappy.positionals.len


proc nth*(crappy: CrappyCli, position: int): string {.noSideEffect.} =
    ## Gets the nth positional argument or "".
    result = ""
    if position > 0 and crappy.positionals.len >= position and crappy.positionals[position - 1].len > 0:
        result = crappy.positionals[position - 1]


proc first*(crappy: CrappyCli): string {.noSideEffect.} =
    ## Grabs the 1st positional argument or "".
    result = crappy.nth 1


proc second*(crappy: CrappyCli): string {.noSideEffect.} =
    ## Grabs the 2nd positional argument or "".
    result = crappy.nth 2


proc third*(crappy: CrappyCli): string {.noSideEffect.} =
    ## Grabs the 3rd positional argument or "".
    result = crappy.nth 3


proc last*(crappy: CrappyCli): string {.noSideEffect.} =
    ## Grabs the last positional argument or "".
    result = crappy.nth crappy.positionals.len


proc switchCount*(crappy: CrappyCli): int {.noSideEffect.} =
    ## Counts the number of switches.
    result = crappy.switches.len


proc has*(crappy: CrappyCli, name: string): bool {.noSideEffect.} =
    ## Do we have a switch with the given name?
    result = crappy.switches.hasKey name


proc `[]`*(crappy: CrappyCli, name: string): string {.noSideEffect.} =
    ## Gets the value of a switch or "".
    result = ""
    if crappy.switches.hasKey(name) and crappy.switches[name].len > 0:
        result = crappy.switches[name]


proc empty*(crappy: CrappyCli): bool {.noSideEffect.} =
    ## Checks if anything at all was passed as a switch or positional.
    result = crappy.switches.len == 0 and crappy.positionals.len == 0


proc newCrappyCli*(
    params: seq[string] = commandLineParams(),
    flags: seq[string] = @[],
): CrappyCli =
    ## Normalizes and organizes the command line arguments.
    new result

    # set the default values
    result.positionals = @[]
    result.switches = initTable[string, string]()

    var skipNext = false
    let filteredParams = params.filterIt it.len > 0

    for i, arg in filteredParams.pairs:
        if skipNext:
            # should we skip this param (cuz its the value of a switch?)
            skipNext = false
        else:
            # clean up the inbound argument
            let
                arg = arg.strip
                argName = arg.removeSwitchToken

            if arg.isSwitch:
                var value = ""

                # peek at next argument, if it is not a switch, let's read the value
                if not flags.contains(argName) and i + 1 < filteredParams.len and not filteredParams[i + 1].isSwitch:
                    value = filteredParams[i + 1].strip
                    skipNext = true

                result.switches.add argName, value

            elif arg.len > 0:
                # this is a positional
                result.positionals.add arg
