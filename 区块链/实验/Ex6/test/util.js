const chai = require("chai");
const snarkjs = require("snarkjs");
const assert = chai.assert;

function assertWitnessHas(circuit, witness, name, value) {
    const signal = `main.${name}`;
    assert(witness[circuit.signalName2Idx[signal]].equals(snarkjs.bigInt(value)),
            `${signal} expected to be ${(snarkjs.bigInt(value))} but was ${witness[circuit.signalName2Idx[signal]]}`);
}

module.exports = {
    assertWitnessHas,
};
