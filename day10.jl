using JuMP
using HiGHS

# Simple BFS solution
function solve(goal::Vector{Bool}, buttons::Vector{Vector{Int}})::Int
  q = Vector{Tuple{Vector{Bool}, Int}}()
  push!(q, (fill(false, length(goal)), 0))
  head = 1

  visited = Set{Vector{Bool}}()
  push!(visited, q[1][1])

  while !isempty(q)
    state, presses = q[head]
    head += 1

    if state == goal
      return presses
    end

    for button in buttons
      new_state = copy(state)
      for idx in button
        new_state[idx] = !new_state[idx]
      end

      if !(new_state in visited)
        push!(visited, new_state)
        push!(q, (new_state, presses + 1))
      end
    end
  end
  return -1
end

# Yay, linear algebra!
# Apparently it was a convenient day to choose Julia.
function solve(goal::Vector{Int}, buttons::Vector{Vector{Int}})::Int
  M = zeros(Int, length(goal), length(buttons))
  for (j, btn) in enumerate(buttons)
    for i in btn
      M[i, j] += 1
    end
  end

  # Want to solve Ax = goal
  model = Model(HiGHS.Optimizer)
  set_optimizer_attribute(model, "log_to_console", false)
  @variable(model, x[1:length(buttons)] >= 0, Int)
  @constraint(model, M * x .== goal)
  @objective(model, Min, sum(x))
  optimize!(model)

  x_opt = value.(x)
  return sum(x_opt)
end

function main()
  part1 = 0
  part2 = 0
  for line in eachline(stdin)
    parts = collect(eachsplit(line, " "))
    goal = [c == '#' for c in parts[1][2:end-1]]
    buttons = [
      parse.(Int, split(strip(s, ['(', ')']), ',')) .+ 1
      for s in parts[2:end-1]
    ]
    joltages = parse.(Int, split(strip(parts[end], ['{', '}']), ','))

    part1 += solve(goal, buttons)
    part2 += solve(joltages, buttons)
  end
  println("Part 1: $part1")
  println("Part 2: $part2")
end

main()
