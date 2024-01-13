const chai = require("chai");
const path = require("path");
const snarkjs = require("snarkjs");
const compiler = require("circom");
const bigInt = require("big-integer");
const { assertWitnessHas } = require("./util.js");

chai.should();

describe("SelectiveSwitch", () => {
    var circ;

    before(async () => {
        circ = new snarkjs.Circuit(
            await compiler(
                path.join(__dirname, "circuits", "selective_switch.circom")));
    });

    it("should not switch when s = 0", async () => {
        const input = {
            "s": "0",
            "in0": "10",
            "in1": "11",
        };
        const witness = circ.calculateWitness(input);
        assertWitnessHas(circ, witness, "out0", "10");
        assertWitnessHas(circ, witness, "out1", "11");
    });

    it("should switch when s = 1", async () => {
        const input = {
            "s": "1",
            "in0": "10",
            "in1": "11",
        };
        const witness = circ.calculateWitness(input);
        assertWitnessHas(circ, witness, "out0", "11");
        assertWitnessHas(circ, witness, "out1", "10");
    });

    it("should enforce that s in {0, 1}", async () => {
        const input = {
            "s": "2",
            "in0": "10",
            "in1": "11",
        };
        (() => circ.calculateWitness(input)).should.throw(
            Error,
            "Constraint doesn't match",
            "Expected non-binary s to violate constraints"
        );
    });
});

