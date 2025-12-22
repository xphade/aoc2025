#!/usr/bin/env python3

import argparse
import sys
from pathlib import Path
from typing import Dict, List, Set

START_TOKEN = "S"
SPLIT_TOKEN = "^"


def count_splits(tachyon_manifold: List[str], beam_start: int) -> int:
    """Counts how often a beam splits according to the `tachyon_manifold`.

    The beam starts at the given `beam_start`. It then splits every time it encounters the split
    token. If there are two beams at the same location, they merge into one. The function uses a
    set to keep the track of the different beam locations.
    """
    beams: Set[int] = {beam_start}
    splits = 0

    for row in tachyon_manifold:
        updated_beams = set()
        for beam in beams:
            if row[beam] == SPLIT_TOKEN:
                updated_beams.add(beam - 1)
                updated_beams.add(beam + 1)
                splits += 1
            else:
                updated_beams.add(beam)
        beams = updated_beams

    return splits


def count_timelines(tachyon_manifold: List[str], beam_start: int) -> int:
    """Counts the total number of timelines in the given `tachyon_manifold`.

    The beam starts at the given `beam_start`. It creates a new timeline every time it encounters
    a split token. The function uses a dictionary to keep track of the number of timelines at each
    beam location.
    """
    timelines: Dict[int, int] = {beam_start: 1}

    for row in tachyon_manifold:
        updated_timelines: Dict[int, int] = {}
        for beam, tl_count in timelines.items():
            if row[beam] == SPLIT_TOKEN:
                updated_timelines[beam - 1] = updated_timelines.get(beam - 1, 0) + tl_count
                updated_timelines[beam + 1] = updated_timelines.get(beam + 1, 0) + tl_count
            else:
                updated_timelines[beam] = updated_timelines.get(beam, 0) + tl_count
        timelines = updated_timelines

    return sum(timelines.values())


def main():
    parser = argparse.ArgumentParser(description="Solve the day 07 challenge of AOC 2025")
    parser.add_argument("input_file", type=Path)
    args = parser.parse_args()
    input_file: Path = args.input_file

    if not input_file.exists():
        print(f"Given file '{input_file}' does not exist")
        sys.exit(1)

    with open(input_file, "r") as file:
        tachyon_manifold = file.read().splitlines()

    # The whole solution assumes valid inputs. I.e., there must be a start token in the first row.
    # Also, there is no bound-checking for the tachyon manifold, so it assumes that there are no
    # split tokens at the left or right edges of the manifold.
    beam_start = tachyon_manifold[0].find(START_TOKEN)

    splits = count_splits(tachyon_manifold[1:], beam_start)
    print(f"Solution to part 1: {splits}")

    timelines = count_timelines(tachyon_manifold[1:], beam_start)
    print(f"Solution to part 2: {timelines}")


if __name__ == "__main__":
    main()
