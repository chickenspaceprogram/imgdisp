#include "huffman.hpp"
#include <functional>
#include <queue>

namespace {

struct HuffmanNode;
struct HuffmanLeaf {
	uint8_t chr;
};
// ugly
struct HuffmanInternal {
	std::shared_ptr<HuffmanNode> lchild;
	std::shared_ptr<HuffmanNode> rchild;
};


struct HuffmanNode {
	std::variant<HuffmanLeaf, HuffmanInternal> node;
	size_t weight;
	bool operator>(const HuffmanNode &node) const {
		return weight > node.weight;
	}
};


template <typename T>
using min_heap = std::priority_queue<T, std::vector<T>, std::greater<T>>;

HuffmanNode gen_tree(std::string_view txt)
{
	std::array<size_t, 0x100> out = {};
	for (size_t i = 0; i < txt.size(); ++i) {
		++out[txt[i]];
	}
	min_heap<HuffmanNode> heap;
	for (size_t i = 0; i < 0x100; ++i) {
		heap.push(HuffmanNode{
			.weight = out[i],
			.node = HuffmanLeaf{.chr = (uint8_t)i},
		});
	}
	while (heap.size() > 1) {
		HuffmanNode node1 = heap.top();
		heap.pop();
		HuffmanNode node2 = heap.top();
		heap.pop();
		heap.push(HuffmanNode {
			.weight = node1.weight + node2.weight,
			.node = HuffmanInternal {
				.lchild = std::make_shared<HuffmanNode>(node1),
				.rchild = std::make_shared<HuffmanNode>(node2),
			},
		});
	}
	return heap.top();

}


inline void make_dict_internal(HuffmanNode &node, std::vector<bool> &pathvec, HuffmanDict &dict) {
	if (node.node.index() == 0) {
		dict[std::get<0>(node.node).chr] = pathvec;
		return;
	}
	pathvec.push_back(0);
	make_dict_internal(*std::get<1>(node.node).lchild, pathvec, dict);
	pathvec.back() = 1;
	make_dict_internal(*std::get<1>(node.node).rchild, pathvec, dict);
	pathvec.pop_back();

}

HuffmanDict make_dict(HuffmanNode &node)
{
	HuffmanDict dict;
	std::vector<bool> pathvec;
	make_dict_internal(node, pathvec, dict);
	return dict;
}


}

HuffmanDict get_huffman_encoder(std::string_view txt)
{
	HuffmanNode node = gen_tree(txt);
	return make_dict(node);
}

std::ostream &operator<<(std::ostream &out, const HuffmanDict &dict)
{
	for (const auto &elem : dict) {
		for (bool bl : elem) {
			out << bl;
		}
		out << '\n';
	}
	out.flush();
	return out;
}
