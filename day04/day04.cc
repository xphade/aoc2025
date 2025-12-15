#include <algorithm>
#include <cstddef>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>
#include <string>
#include <string_view>
#include <vector>

namespace {

constexpr auto kRollSymbol{'@'};
constexpr int kRollThreshold{4};

// Reads the contents of the file at the given `path`, or `std::nullopt` if file
// cannot be opened. The implementation is not a super efficient way to read a
// file, but good enough for our usecase.
std::optional<std::string> ReadFile(const std::filesystem::path &path) {
  std::ifstream istream{path};
  if (!istream.is_open()) {
    return std::nullopt;
  }
  std::ostringstream sstream{};
  sstream << istream.rdbuf();
  return sstream.str();
}

// Creates the map as a vector of strings from the input file `contents`.
// Assumes that the file ends with a newline character ("\n"). The map
// coordinate system in subsequent functions is defined like this:
//
//  +---------> y
//  | ..@@.@@@
//  | @@@.@.@.
//  | @@@@@.@.
//  v @.@@@@..
//  x
//
std::vector<std::string> CreateMap(const std::string_view contents) {
  std::vector<std::string> map{};
  size_t last{0}, next{0};

  constexpr auto kDelimiter{"\n"};
  while ((next = contents.find(kDelimiter, last)) != std::string::npos) {
    map.push_back(std::string{contents.substr(last, next - last)});
    last = next + 1;
  }
  return map;
}

// Returns a string containing the adjacent elements in the `map` at location
// `(pos_x, pos_y)`. Returns a maximum of 8 elements, or less at the border of
// the map.
std::string GetAdjacentElements(const std::vector<std::string> &map,
                                const std::size_t pos_x,
                                const std::size_t pos_y) {
  const auto m = map.size();
  const auto n = map[0].size();

  std::string elements{};
  static constexpr int kMaxElements{8};
  elements.reserve(kMaxElements);
  for (int i = -1; i <= 1; ++i) {
    for (int j = -1; j <= 1; ++j) {
      if (i == 0 && j == 0) {
        continue;
      }

      const auto x = pos_x + i;
      const auto y = pos_y + j;
      if (x < 0 || x >= m || y < 0 || y >= n) {
        continue;
      }
      elements += map[x][y];
    }
  }
  return elements;
}

// Returns the number of immediately accessible paper rolls as located in the
// given `map`. A location is defined as accessible if there are less than
// `kRollThreshold` paper rolls in its adjacent locations.
int GetNumberOfAccessiblePaperRolls(const std::vector<std::string> &map) {
  int rolls{0};

  for (std::size_t x = 0; x < map.size(); ++x) {
    for (std::size_t y = 0; y < map[0].size(); ++y) {
      if (map[x][y] != kRollSymbol) {
        continue;
      }

      const auto elements = GetAdjacentElements(map, x, y);
      const auto adjacent_rolls =
          std::count(elements.cbegin(), elements.cend(), kRollSymbol);

      if (adjacent_rolls < kRollThreshold) {
        ++rolls;
      }
    }
  }
  return rolls;
}

// Returns the total number of paper rolls located in the `map` which can be
// removed. For a roll to be removed, it must be accessible, which it is if
// there are less than `kRollThreshold` paper rolls in its adjacent locations.
// The map will be processed as long as there's still paper rolls available for
// removal.
int GetNumberOfRemovablePaperRolls(std::vector<std::string> map) {
  int rolls{0};
  bool removed_rolls{true};

  while (removed_rolls) {
    removed_rolls = false;

    for (std::size_t x = 0; x < map.size(); ++x) {
      for (std::size_t y = 0; y < map[0].size(); ++y) {
        if (map[x][y] != kRollSymbol) {
          continue;
        }

        const auto elements = GetAdjacentElements(map, x, y);
        const auto adjacent_rolls =
            std::count(elements.cbegin(), elements.cend(), kRollSymbol);

        if (adjacent_rolls < kRollThreshold) {
          ++rolls;
          map[x][y] = '.';
          removed_rolls = true;
        }
      }
    }
  }
  return rolls;
}

} // namespace

int main(int argc, char *argv[]) {
  if (argc != 2) {
    std::cerr << "Usage: " << argv[0] << " <input_file>" << std::endl;
    return EXIT_FAILURE;
  }

  const auto file_path = std::filesystem::path{argv[1]};
  if (!std::filesystem::exists(file_path)) {
    std::cerr << "Given file does not exist" << std::endl;
    return EXIT_FAILURE;
  }

  const auto contents = ReadFile(file_path);
  if (!contents.has_value()) {
    std::cerr << "Failed opening file" << std::endl;
    return EXIT_FAILURE;
  }

  // NOTE: We don't do any additional map validation, we just assume the file
  // contains valid map data.
  auto map = CreateMap(*contents);

  std::cout << "Solution to part 1: " //
            << GetNumberOfAccessiblePaperRolls(map) << std::endl;
  std::cout << "Solution to part 2: "
            << GetNumberOfRemovablePaperRolls(std::move(map)) << std::endl;

  return EXIT_SUCCESS;
}
