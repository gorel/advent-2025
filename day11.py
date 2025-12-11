#!/usr/bin/env python3

import collections
import functools
import sys


def dfs(g: dict[str, set[str]], src: str, dst: str) -> int:
    @functools.cache
    def count_from(cur: str) -> int:
        if cur == dst:
            return 1
        return sum(count_from(adj) for adj in g[cur])

    return count_from(src)


def main() -> None:
    g = collections.defaultdict(set)
    for line in sys.stdin:
        lhs, rhs = line.strip().split(":", 1)
        g[lhs] = {o for o in rhs[1:].split(" ")}

    part1 = dfs(g, "you", "out")
    print(part1)

    # Find paths visiting svr->out
    # that also visit dac + fft
    # Options:
    #   * svr->dac->fft->out
    #   * svr->fft->dac->out
    svr_to_dac = dfs(g, "svr", "dac")
    svr_to_fft = dfs(g, "svr", "fft")
    dac_to_fft = dfs(g, "dac", "fft")
    fft_to_dac = dfs(g, "fft", "dac")
    dac_to_out = dfs(g, "dac", "out")
    fft_to_out = dfs(g, "fft", "out")
    # First option is ways to dac * ways from dac to fft * ways from fft to out
    svr_dac_fft_out = svr_to_dac * dac_to_fft * fft_to_out
    # Second option is ways to fft * ways from fft to dac * ways from dac to out
    svr_fft_dac_out = svr_to_fft * fft_to_dac * dac_to_out
    part2 = svr_dac_fft_out + svr_fft_dac_out
    print(part2)


if __name__ == "__main__":
    main()
