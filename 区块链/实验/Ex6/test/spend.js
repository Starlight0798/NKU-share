const chai = require("chai");
const path = require("path");
const fs = require('fs');
const snarkjs = require("snarkjs");
const compiler = require("circom");

chai.should();

describe("Spend", () => {
    const tests = [
        { id: 0, depth: 0 },
        { id: 1, depth: 4 },
        { id: 2, depth: 25 },
    ];
    for (const { id, depth } of tests) {
        it(`witness computable for depth ${id}`, async () => {
            const circ = new snarkjs.Circuit(
                await compiler(
                    path.join(__dirname, "circuits", `spend${depth}.circom`)));
            const inPath = path.join(
                __dirname, "compute_spend_inputs", `out${id}.txt`)
            const input = JSON.parse(fs.readFileSync(inPath, { encoding: 'utf8' }));
            const witness = circ.calculateWitness(input);
        });
    }
    it(`witness not computable for bad input`, async () => {
        const circ = new snarkjs.Circuit(
            await compiler(
                path.join(__dirname, "circuits", `spend25.circom`)));
        const inPath = path.join(
            __dirname, "compute_spend_inputs", `out-bad.txt`)
        const input = JSON.parse(fs.readFileSync(inPath, { encoding: 'utf8' }));
        (() => circ.calculateWitness(input)).should.throw(
            Error,
            "Constraint doesn't match",
            "Expected bad inputs to crash witness computation"
        )
    });
});

