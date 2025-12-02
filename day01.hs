rotate :: Int -> (Char, Int) -> Int
rotate init (dir, dist) =
  case dir of
    'L' -> (init - dist) `mod` 100
    'R' -> (init + dist) `mod` 100
    _ -> error "Invalid direction"

countZeros :: [(Char, Int)] -> Int
countZeros moves = length $ filter (== 0) finalPositions
  where
    finalPositions = tail $ scanl rotate 50 moves

numZeroPasses :: Int -> (Char, Int) -> Int
numZeroPasses init (dir, dist) =
  let positions = case dir of
                    'L' -> [ (init - i) `mod` 100 | i <- [1..dist] ]
                    'R' -> [ (init + i) `mod` 100 | i <- [1..dist] ]
                    _ -> error "Invalid direction"
  in length $ filter (== 0) positions

countZeroPasses :: [(Char, Int)] -> Int
countZeroPasses moves =
  let (_, totalPasses) = foldl step (50, 0) moves
  in  totalPasses
  where
    step (pos, total) move =
      let newPasses = numZeroPasses pos move
          newPos    = rotate pos move
      in  (newPos, total + newPasses)

parseLine :: String -> (Char, Int)
parseLine line =
  let dir = head line
      dist = read (tail line) :: Int
  in (dir, dist)

parseMovesFromStdin :: IO [(Char, Int)]
parseMovesFromStdin = do
  contents <- getContents
  let ls = lines contents
  return $ map parseLine ls

main :: IO ()
main = do
  moves <- parseMovesFromStdin
  let part1 = countZeros moves
  print part1
  let part2 = countZeroPasses moves
  print part2
