function main()
  lines = String[]
  for line in eachline(stdin)
    println("Line: ", line)
    push!(lines, line)
  end
  println("Lines: ", lines)
end

main()
