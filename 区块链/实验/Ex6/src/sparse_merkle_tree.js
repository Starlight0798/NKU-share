const { mimc2 } = require("./mimc.js");
const assert = require('assert').strict;

class SparseMerkleTree {
    /*
     * Constructs a new sparse merkle tree.
     * This is an insert-only set which is reprented by a single 
     *
     * depth: the number of non-root layers in the tree
     *
     * Note: for the purposes of computing the digest of the tree, unoccupied nodes should be taken to have value `0n`.
     */
    constructor(depth) {
        this.depth = depth;
        this.defaults = ["0"];
        while (this.defaults.length < depth + 1) {
            const last = this.defaults[this.defaults.length - 1];
            this.defaults.push(mimc2(last, last));
        }
        this.defaults.reverse();
        this.nodes = {};
        this.leaf_indices = {};
        this.next_index = 0;
    }

    /*
     * Returns the merkle digest of the tree.
     * A string.
     */
    get digest() {
        return this.node(0, 0);
    }

    /*
     * Adds an item to the merkle tree, in the next open leaf.
     * Asserts the novelty of the item.
     * Asserts that there is space for the item.
     */
    insert(item) {
        item = item.toString();
        assert.ok(!(item in this.leaf_indices));
        assert.ok(this.next_index < 2 ** this.depth);
        let index = this.next_index++;
        this.leaf_indices[item] = index;
        this.nodes[[this.depth, index]] = item;
        let level = this.depth;
        while (level > 0) {
            level--;
            index = Math.floor(index / 2);
            const left = this.node(level + 1, 2 * index);
            const right = this.node(level + 1, 2 * index + 1);
            this.nodes[[level, index]] = mimc2(left, right);
        }
    }

    /*
     * For an item in the merkle tree, return the path for that item.
     * The path is an array of (sibling, direction) pairs where
     * the sibling is the hash at a node adjacent to the path
     * the direction is a boolean indicating whether that sibling is to the left of the path
     * and the first sibling in the array is the sibling of the **leaf** with item.
     * (i.e. the path goes from the leaf to the root)
     *
     * Note that the path has length equal to the depth.
     * Note that the root of the tree is **not** in the path.
     */
    path(item) {
        assert.ok(item in this.leaf_indices);
        let index = this.leaf_indices[item];
        let level = this.depth;
        let path = [];
        while (level > 0) {
            const direction = !!(index & 1);
            level--;
            index = Math.floor(index / 2);
            const sibling = this.node(level + 1, 2 * index + (1 - direction));
            path.push([sibling, direction]);
        }
        return path;
    }

    node(level, index) {
        if ([level, index] in this.nodes) {
            return this.nodes[[level, index]];
        } else {
            return this.defaults[level];
        }
    }

}

module.exports = {
    SparseMerkleTree,
};
