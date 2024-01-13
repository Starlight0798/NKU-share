const chai = require("chai");
const path = require("path");
const snarkjs = require("snarkjs");
const compiler = require("circom");
const bigInt = require("big-integer");
const { assertWitnessHas } = require("./util.js");

chai.should();

describe("IfThenElse", () => {
    var circ;

    before(async () => {
        circ = new snarkjs.Circuit(
            await compiler(
                path.join(__dirname, "circuits", "if_then_else.circom")));
    });

    it("should give `false_value` when `condition` = 0", async () => {
        const input = {
            "condition": "0",
            "false_value": "10",
            "true_value": "11",
        };
        const witness = circ.calculateWitness(input);
        assertWitnessHas(circ, witness, "out", "10");
    });

    it("should give `true_value` when `condition` = 1", async () => {
        const input = {
            "condition": "1",
            "false_value": "10",
            "true_value": "11",
        };
        const witness = circ.calculateWitness(input);
        assertWitnessHas(circ, witness, "out", "11");
    });

    it("should enforce that s in {0, 1}", async () => {
        const input = {
            "condition": "2",
            "false_value": "10",
            "true_value": "11",
        };
        (() => circ.calculateWitness(input)).should.throw(
            Error,
            "Constraint doesn't match",
            "Expected non-binary s to violate constraints"
        );
    });
});

