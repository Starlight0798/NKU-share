const { docopt } = require("docopt");
const { mimc2 } = require("./mimc.js");
const { SparseMerkleTree } = require("./sparse_merkle_tree.js");
const fs = require("fs");
const doc = `Usage:
  compute_spend_inputs.js [options] <depth> <transcript> <nullifier>
  compute_spend_inputs.js -h | --help

Options:
  -o <file>     name of the created witness file [default: input.json]
  -h --help     Print this message

Arguments:
   <depth>       The number of non-root layers in the merkle tree.
   <transcript>  The file containing transcript of all coins.
                 A file with a line for each coin.
                 Each coin is either a single number (the coin
                 itself) or it can be two space-separated number, which are, in
                 order, the nullifier and the nonce for the coin.

                 Example:

                     1839475893
                     1984375234 2983475298
                     3489725451 9834572345
                     3452345234

   <nullifier>   The nullifier to print a witness of validity for.
                 Must be present in the transcript.
`

/*
 * Computes inputs to the Spend circuit.
 *
 * Inputs:
 *   depth: the depth of the merkle tree being used.
 *   transcript: A list of all coins added to the tree.
 *               Each item is an array.
 *               If the array hash one element, then that element is the coin.
 *               Otherwise the array will have two elements, which are, in order:
 *                 the nullifier and
 *                 the nonce
 *               This list will contain **no** duplicate nullifiers or coins.
 *   nullifier: The nullifier to print inputs to validity verifier for.
 *              This nullifier will be one of the nullifiers in the transcript.
 *
 * Return:
 *   an object of the form:
 * {
 *   "digest"            : ...,
 *   "nullifier"         : ...,
 *   "nonce"             : ...,
 *   "sibling[0]"        : ...,
 *   "sibling[1]"        : ...,
 *      ...
 *   "sibling[depth-1]"  : ...,
 *   "direction[0]"      : ...,
 *   "direction[1]"      : ...,
 *      ...
 *   "direction[depth-1]": ...,
 * }
 * where each ... is a string-represented field element (number)
 * notes about each:
 *   "digest": the digest for the whole tree after the transcript is
 *                  applied.
 *   "nullifier": the nullifier for the coin being spent.
 *   "nonce": the nonce for that coin
 *   "sibling[i]": the sibling of the node on the path to this coin
 *                 at the i'th level from the bottom.
 *   "direction[i]": "0" or "1" indicating whether that sibling is on the left.
 *       The "sibling" hashes correspond directly to the siblings in the
 *       SparseMerkleTree path.
 *       The "direction" keys the boolean directions from the SparseMerkleTree
 *       path, casted to string-represented integers ("0" or "1").
 */
function computeInput(depth, transcript, nullifier) {
    // TODO
    const tree = new SparseMerkleTree(depth);

    // 存储我们想要生成验证的给定 nullifier 对应的 commitment。
    let input_commitment, input_nonce = [null, null];

    // 将 transcript 添加到树中。
    for (let i = 0; i < transcript.length; i++) {
      const commitment_or_info = transcript[i];
      let commitment = null;
      if (commitment_or_info.length == 1) {
        commitment = commitment_or_info[0];
      } else if (commitment_or_info.length == 2) {
        const [t_nullifier, nonce] = commitment_or_info;
        commitment = mimc2(t_nullifier, nonce);
        if (nullifier == t_nullifier) {
          if (input_commitment != null) {
            throw "有重复!";
          }
          [input_commitment, input_nonce] = [commitment, nonce];
        }
      } else {
        throw "Transcript 无效 + " + str(transcript);
      }
      if (commitment == null) {  
        throw "commitment为空!";
      }
      tree.insert(commitment);
    }

    // 获取我们的项目的证明。
    if (input_commitment == null) {
      throw "nullifier 在我们的 transcript 中未找到";
    }
    const path = tree.path(input_commitment);
    const output = {
      digest: tree.digest,
      nullifier: nullifier,
      nonce: input_nonce,
    };
    for (let i = 0; i < depth; i++) {
      let [s, d] = path[i];
      output['sibling[' + i + ']'] = s.toString();
      output['direction[' + i + ']'] = (d) ? "1" : "0";
    }
    return output;
}

module.exports = { computeInput };

// If we're not being imported
if (!module.parent) {
    const args = docopt(doc);
    const transcript =
        fs.readFileSync(args['<transcript>'], { encoding: 'utf8' } )
        .split(/\r?\n/)
        .filter(l => l.length > 0)
        .map(l => l.split(/\s+/));
    const depth = parseInt(args['<depth>']);
    const nullifier = args['<nullifier>'];
    const input = computeInput(depth, transcript, nullifier);
    fs.writeFileSync(args['-o'], JSON.stringify(input) + "\n");
}
