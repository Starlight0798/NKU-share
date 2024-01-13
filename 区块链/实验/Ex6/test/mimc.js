const chai = require("chai");
const path = require("path");
const snarkjs = require("snarkjs");
const compiler = require("circom");
const bigInt = require("big-integer");
const { mimc2, mimc_cipher } = require("../src/mimc.js");
const { assertWitnessHas } = require("./util.js");

chai.should();

describe("Mimc2 function", () => {
    it("should run on integers", async () => {
        mimc2(0, 0)
    });
    it("should run on strings", async () => {
        mimc2("0", "1")
    });
    it("should run on big integers", async () => {
        mimc2(bigInt("0"), bigInt("1"))
    });
});

describe("Mimc(x^7) cipher circuit", () => {
    var mimc;

    before(async () => {
        mimc = new snarkjs.Circuit(
            await compiler(
                path.join(__dirname, "circuits", "mimc_cipher.circom")));
    });

    it("shouldn't crash when witnessing", async () => {
        const input = {
            "x_in": "0",
            "k": "0",
        };
        const witness = mimc.calculateWitness(input);
    });

    it("should agree with the function on 0, 1", async () => {
        const input = {
            "x_in": "0",
            "k": "0",
        };
        const witness = mimc.calculateWitness(input);
        const expected = mimc_cipher(bigInt(0n), bigInt(0n)).value;
        assertWitnessHas(mimc, witness, "out", expected);
    });
});

describe("Mimc2 circuit", () => {
    var mimc;

    before(async () => {
        mimc = new snarkjs.Circuit(
            await compiler(
                path.join(__dirname, "circuits", "mimc.circom")));
    });

    it("should have 364 constraints", async () => {
        mimc.nConstraints.should.equal(364);
    });

    it("shouldn't crash when witnessing", async () => {
        const input = {
            "in0": "0",
            "in1": "1",
        };
        const witness = mimc.calculateWitness(input);
    });

    it("should agree with the function on 0, 1", async () => {
        const input = {
            "in0": "0",
            "in1": "1",
        };
        const witness = mimc.calculateWitness(input);
        const expected = mimc2(0, 1);
        assertWitnessHas(mimc, witness, "out", expected);
    });
});
