package main

import "core:fmt"
import "core:os"
import "core:strings"

build_grid :: proc(s: string) -> [dynamic][dynamic]rune {
  lines := strings.split_lines(s);
  g : [dynamic][dynamic]rune;
  for line in lines {
    r: [dynamic]rune;
    for c in line {
      append(&r, c);
    }
    append(&g, r);
  }
  return g;
}

safe_adj :: proc(g: [dynamic][dynamic]rune, r: int, c: int) -> int {
  res := 0;
  for i in -1..=1 {
    for j in -1..=1 {
      if i == 0 && j == 0 {
        continue;
      }
      nr := r + i;
      nc := c + j;
      if nr >= 0 && nr < len(g) && nc >= 0 && nc < len(g[nr]) {
        if g[nr][nc] == '@' {
          res += 1;
        }
      }
    }
  }
  return res;
}

main :: proc() {
  contents, ok := os.read_entire_file(os.stdin);
  if !ok {
    fmt.eprintln("failed to read stdin");
    return;
  }
  defer delete(contents);

  g := build_grid(string(contents));
  defer {
    for row in g {
      delete(row);
    }
    delete(g);
  }

  part1 := 0;
  for r in 0..<len(g) {
    for c in 0..<len(g[r]) {
      if g[r][c] == '@' && safe_adj(g, r, c) < 4 {
        part1 += 1;
      }
    }
  }
  fmt.println(part1);

  part2 := 0;
  updated := true;
  for updated {
    updated = false;
    for r in 0..<len(g) {
      for c in 0..<len(g[r]) {
        if g[r][c] == '@' && safe_adj(g, r, c) < 4 {
          updated = true;
          g[r][c] = '.'
          part2 += 1;
        }
      }
    }
  }
  fmt.println(part2);
}
