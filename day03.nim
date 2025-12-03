import strutils, sequtils

proc parseLine(line: string): seq[int] =
  line.split(",").mapIt(it.parseInt())

proc solve1(data: seq[seq[int]]): int = 0

proc solve2(data: seq[seq[int]]): int = 0

when isMainModule:
  let input = readAll(stdin).strip()
  let lines = input.splitLines()
  let data = lines.map(parseLine)

  echo solve1(data)
  echo solve2(data)
