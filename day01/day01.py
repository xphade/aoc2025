#!/usr/bin/env python3

import argparse
from pathlib import Path
from typing import List, Tuple

DIAL_SIZE = 100
START_POSITION = 50


def parse_input(file_path: Path) -> List[str]:
    with open(file_path, "r") as file:
        return file.read().splitlines()


def split_instruction(instruction: str) -> Tuple[str, int]:
    direction, rotations = (instruction[0], int(instruction[1:]))
    if direction not in {"L", "R"} or rotations <= 0:
        raise ValueError(f"Invalid instruction: '{instruction}'")
    return direction, rotations


def determine_password(instructions: List[str]) -> int:
    """Determines the password according to the original specification.

    This function solves part 1 of AOC 2025 day 1. It counts how many times the dial ends at
    position 0 after each instruction.
    """
    position = START_POSITION
    count = 0

    for instruction in instructions:
        direction, rotations = split_instruction(instruction)

        if direction == "L":
            position -= rotations
        else:  # direction == "R":
            position += rotations

        position %= DIAL_SIZE
        if position == 0:
            count += 1

    return count


def determine_password_0x434C49434B(instructions: List[str]) -> int:
    """Determines the password according to method 0x434C49434B.

    This function solves part 2 of AOC 2025 day 1. It counts how many times any click causes the
    dial to point at 0, regardless of whether it happens during a rotation or at the end of one.
    """
    position = START_POSITION
    count = 0

    for instruction in instructions:
        direction, rotations = split_instruction(instruction)

        # Count full rotations and keep remainder.
        count += rotations // DIAL_SIZE
        rotations %= DIAL_SIZE

        original_position = position
        if direction == "L":
            position -= rotations
        else:  # direction == "R":
            position += rotations

        dial_passed_zero = original_position != 0 and (position % DIAL_SIZE) != position
        if position == 0 or dial_passed_zero:
            count += 1

        position %= DIAL_SIZE

    return count


def main():
    parser = argparse.ArgumentParser(description="Solve the day 01 challenge of AOC 2025")
    parser.add_argument("input_file", type=Path)
    args = parser.parse_args()
    input_file: Path = args.input_file

    if not input_file.exists():
        raise RuntimeError(f"Input '{input_file}' does not exist")

    instructions = parse_input(input_file)

    password = determine_password(instructions)
    print(f"Solution to part 1: {password}")

    password_0x434C49434B = determine_password_0x434C49434B(instructions)
    print(f"Solution to part 2: {password_0x434C49434B}")


if __name__ == "__main__":
    main()
