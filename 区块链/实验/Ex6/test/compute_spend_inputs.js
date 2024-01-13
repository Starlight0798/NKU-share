const path = require("path");
const chai = require("chai");
const fs = require('fs');
const { computeInput } = require("../src/compute_spend_inputs.js");
const { SparseMerkleTree } = require("../src/sparse_merkle_tree.js");
const { mimc2 } = require("../src/mimc.js");

chai.should();

describe("computeInput", () => {
    const tests = [
        { id: 0, depth: 0, nullifier: "1" },
        { id: 1, depth: 4, nullifier: "4" },
        { id: 2, depth: 25, nullifier: "7" },
    ];

    for (const { id, depth, nullifier } of tests) {
        it(`transcript${id}.txt, depth ${depth}, nullifier ${nullifier}`, async () => {
            const transcriptPath = path.join(
                __dirname, "compute_spend_inputs", `transcript${id}.txt`)
            const expectedOutPath = path.join(
                __dirname, "compute_spend_inputs", `out${id}.txt`)
            const transcript =
                fs.readFileSync(transcriptPath, { encoding: 'utf8' } )
                .split(/\r?\n/)
                .filter(l => l.length > 0)
                .map(l => l.split(/\s+/));
            const expectedOut = JSON.parse(fs.readFileSync(expectedOutPath, { encoding: 'utf8' }));
            computeInput(depth, transcript, nullifier).should.be.deep.equal(expectedOut);
        });
    }
});
