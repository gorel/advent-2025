struct Point
  x :: Int64
  y :: Int64
end

function main()
  lines = String[]
  nums = Point[]
  for line in eachline(stdin)
    parts = collect(eachsplit(line, ","))
    x = parse(Int64, parts[1])
    y = parse(Int64, parts[2])
    println("Line: ", line)
    push!(lines, line)
    push!(nums, Point(x, y))
  end
  println("Lines: ", lines)
  println("Points: ", nums)
end

main()
