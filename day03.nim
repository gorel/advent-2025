import strutils, sequtils

proc parseLine(line: string): seq[int] =
  line.mapIt(ord(it) - ord('0'))

proc sub(line: seq[int], leftMin: int, remaining: int): tuple[n: int, idx: int] =
  var hi = 0
  var hiIdx = -1
  for i in leftMin ..< line.len - remaining:
    if line[i] > hi:
      hi = line[i]
      hiIdx = i
  return (hi, hiIdx)

proc solve1(g: seq[seq[int]]): int =
  var res = 0
  for line in g:
    let sub0 = sub(line, 0, 1)
    let sub1 = sub(line, sub0.idx + 1, 0)
    res += 10*sub0.n + sub1.n
  return res

proc solve2(g: seq[seq[int]]): int =
  var res = 0
  for line in g:
    var cur = 0
    var curIdx = -1
    for i in 0 ..< 12:
      let subi = sub(line, curIdx + 1, 11 - i)
      cur = cur*10 + subi.n
      curIdx = subi.idx
    res += cur
  return res

when isMainModule:
  let input = readAll(stdin).strip()
  let lines = input.splitLines()
  let g = lines.map(parseLine)

  echo solve1(g)
  echo solve2(g)
