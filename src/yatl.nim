import os
import base64
import strutils
import terminal

proc readItems(todoFilePath: string): void

when isMainModule:
  # Init todo file
  # Open if exists, create empty if not
  let todoFilePath = absolutePath(getHomeDir() / ".yatl")
  var todoFile: File
  if not fileExists(todoFilePath):
    todoFile = open(todoFilePath, mode = fmWrite)
    close(todoFile)

  if paramCount() == 0:
    readItems(todoFilePath)

  elif paramCount() == 1:
    case paramStr(1)
    of "list", "l":
      readItems(todoFilePath)
    of "add", "append", "a":
      echo "Expected items to add"
    of "done", "d":
      echo "Expected items to mark done"
    else:
      echo "Unknown command"


  elif paramCount() >= 2:
    case paramStr(1)
    # Append a new note to the list
    of "add", "append", "a":
      todoFile = open(todoFilePath, mode = fmAppend)
      for arg in 2 .. paramCount():
        todoFile.writeLine("[ ]" & base64.encode(paramStr(arg)))

    # Mark item as done
    of "done", "d":
      try:
        # Check for every arg to be a positive
        # int32(why would you need more?) number
        # return 1 otherwise
        for arg in 2 .. paramCount():
          if parseInt(paramStr(arg)) <= 0:
            echo "Item number must be ⩾ 1"
            quit(QuitFailure)
      except ValueError:
        echo "Wrong item number"
        quit(QuitFailure)


      var items = readFile(todoFilePath).split('\n')
      items.del(items.high) # Remove empty string from trailing newline
      
      for arg in 2 .. paramCount():
        if parseInt(paramStr(arg))-1 > items.len-1:
          # Iterate throu args and perform sanity check
          echo "Item №", paramStr(arg), " doesn't exist"
          system.quit(QuitFailure)

        # Mark item done
        items[parseInt(paramStr(arg))-1] = items[parseInt(paramStr(
            arg))-1].replace("[ ]", "[d]")

      # Write everythig back to the file
      todoFile = open(todoFilePath, mode = fmWrite)
      for line in items:
        todoFile.writeLine(line)

    else:
      echo "Unknown command"

proc readItems(todoFilePath: string): void =
  todoFile = open(todoFilePath, mode = fmRead)
  for line in todoFile.lines:
    case line[1]:
      of 'd':
        # Print done items striked through
        styledEcho styleStrikethrough, base64.decode(line[3 .. line.high])
      else:
        # Print normally
        echo base64.decode(line[3 .. line.high])
