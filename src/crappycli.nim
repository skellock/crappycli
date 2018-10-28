from strutils import strip, startsWith, parseInt
from tables import initTable, Table, hasKey, `[]`, add, len
from sequtils import filterIt
from os import commandLineParams

type
    CrappyCli* = ref object
        positionals: seq[string]
        switches: Table[string, string]


func isSwitch(value: string): bool {.inline.} =
    # Does this string start with a dash?
    result = value.strip.startsWith "-"


func removeSwitchToken(value: string): string =
    ## Removes upto 2 preceding dashes.
    result = value
    if value.startsWith "--":
        result = value[2..high(value)]
    elif value.startsWith "-":
        result = value[1..high(value)]


func positionalCount*(crappy: CrappyCli): int  =
    ## The number of positionals used.
    result = crappy.positionals.len


func nth*(crappy: CrappyCli, position: int): string =
    ## Gets the nth positional argument or "".
    result = ""
    if position > 0 and crappy.positionals.len >= position and crappy.positionals[position - 1].len > 0:
        result = crappy.positionals[position - 1]


func first*(crappy: CrappyCli): string =
    ## Grabs the 1st positional argument or "".
    result = crappy.nth 1


func second*(crappy: CrappyCli): string =
    ## Grabs the 2nd positional argument or "".
    result = crappy.nth 2


func third*(crappy: CrappyCli): string =
    ## Grabs the 3rd positional argument or "".
    result = crappy.nth 3


func last*(crappy: CrappyCli): string =
    ## Grabs the last positional argument or "".
    result = crappy.nth crappy.positionals.len


func switchCount*(crappy: CrappyCli): int =
    ## Counts the number of switches.
    result = crappy.switches.len


func has*(crappy: CrappyCli, name: string): bool =
    ## Do we have a switch with the given name?
    result = crappy.switches.hasKey name


func `[]`*(crappy: CrappyCli, name: string): string =
    ## Gets the value of a switch or "".
    result = ""
    if crappy.switches.hasKey(name) and crappy.switches[name].len > 0:
        result = crappy.switches[name]


func empty*(crappy: CrappyCli): bool =
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


proc stringValue*(cli: CrappyCli, name: string, fallback: string): string =
    ## Gets a string from a named switch with a falling back if there's a problem.
    result = fallback
    if cli.has(name):
        result = cli[name]


proc intValue*(cli: CrappyCli, name: string, fallback: int): int =
    ## Gets an int from a named switch with a falling back if there's a problem.
    result = fallback
    try:
        if cli.has(name):
            result = parseInt(cli[name])
    except:
        discard
