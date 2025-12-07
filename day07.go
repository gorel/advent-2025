package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type Point struct {
	r, c int
}

type Graph []string

func (g Graph) inbounds(p Point) bool {
	return p.r >= 0 && p.r < len(g) && p.c >= 0 && p.c < len((g)[0])
}

func (g Graph) at(p Point) byte {
	return g[p.r][p.c]
}

// A bit weird since we explicitly iterate bottom-up.
// But we need this behavior for the memoization to work.
func (g Graph) iter() <-chan Point {
	ch := make(chan Point)
	go func() {
		defer close(ch)
		for r := len(g) - 1; r >= 0; r-- {
			for c := 0; c < len(g[r]); c++ {
				ch <- Point{r, c}
			}
		}
	}()
	return ch
}

func (g Graph) dfs() int {
	c := strings.IndexRune(g[0], 'S')
	res := make(map[Point]bool)
	g.dfs_(Point{0, c}, res, make(map[Point]bool))
	return len(res)
}

func (g Graph) dfs_(p Point, splitters map[Point]bool, visited map[Point]bool) {
	if !g.inbounds(p) || visited[p] {
		return
	}
	visited[p] = true

	if g.at(p) == '^' {
		splitters[p] = true
		g.dfs_(Point{p.r, p.c - 1}, splitters, visited)
		g.dfs_(Point{p.r, p.c + 1}, splitters, visited)
	} else {
		g.dfs_(Point{p.r + 1, p.c}, splitters, visited)
	}
}

func (g Graph) paths() int {
	res := make(map[Point]int)
	for p := range g.iter() {
		if g.at(p) == '^' || g.at(p) == 'S' {
			res[p] = g.paths_(p, res)
		}
	}
	c := strings.IndexRune(g[0], 'S')
	return res[Point{0, c}]
}

func (g Graph) paths_(p Point, memo map[Point]int) int {
	var starts []Point
	if g.at(p) == 'S' {
		starts = append(starts, p)
	} else {
		starts = append(starts, Point{p.r, p.c - 1})
		starts = append(starts, Point{p.r, p.c + 1})
	}

	for _, tachyon := range starts {
		for g.inbounds(tachyon) && g.at(tachyon) != '^' {
			tachyon.r++
		}
		if g.inbounds(tachyon) {
			memo[p] += memo[tachyon]
		} else {
			memo[p] += 1
		}
	}
	return memo[p]
}

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var lines []string
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}
	g := Graph(lines)
	fmt.Printf("%d\n", g.dfs())
	fmt.Printf("%d\n", g.paths())
}
