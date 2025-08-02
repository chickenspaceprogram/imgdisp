#pragma once
#include <cstddef>
#include <array>
#include <vector>
#include <ostream>

using HuffmanDict = std::array<std::vector<bool>, 0x100>;

HuffmanDict get_huffman_encoder(std::string_view txt);

std::ostream &operator<<(std::ostream &out, const HuffmanDict &dict);
