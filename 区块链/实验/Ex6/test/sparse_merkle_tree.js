const path = require("path");
const chai = require("chai");
const { SparseMerkleTree } = require("../src/sparse_merkle_tree.js");
const { mimc2 } = require("../src/mimc.js");

chai.should();

describe("SparseMerkleTree(0)", () => {
    it("should be constructable", async () => {
        const smt = new SparseMerkleTree(0);
        smt.should.exist;
        smt.should.be.an.instanceof(SparseMerkleTree);
    });

    it("should have a correct hash when empty", async () => {
        const smt = new SparseMerkleTree(0);
        smt.should.have.property('digest', "0");
    });

    it("should have a correct hash after insert", async () => {
        const smt = new SparseMerkleTree(0);
        smt.insert("5");
        smt.should.have.property('digest', "5");
    });

    it("should give the correct path after insert", async () => {
        const smt = new SparseMerkleTree(0);
        smt.insert("7");
        smt.path("7").should.be.deep.equal([]);
    });
});

describe("SparseMerkleTree(2)", () => {
    it("should be constructable", async () => {
        const smt = new SparseMerkleTree(2);
        smt.should.exist;
        smt.should.be.an.instanceof(SparseMerkleTree);
    });

    it("should have a correct hash when empty", async () => {
        const smt = new SparseMerkleTree(2);
        const h11 = mimc2("0", "0");
        const h12 = mimc2("0", "0");
        const h2 = mimc2(h11, h12);
        smt.should.have.property('digest', h2);
    });

    it("should have a correct hash after 1 insert", async () => {
        const smt = new SparseMerkleTree(2);
        smt.insert("5");
        const h11 = mimc2("5", "0");
        const h12 = mimc2("0", "0");
        const h2 = mimc2(h11, h12);
        smt.should.have.property('digest', h2);
    });

    it("should give a correct path after 1 insert", async () => {
        const smt = new SparseMerkleTree(2);
        smt.insert("5");
        const h11 = mimc2("5", "0");
        const h12 = mimc2("0", "0");
        const h2 = mimc2(h11, h12);
        smt.path("5").should.be.deep.equal([["0", false], [h12, false]]);
    });

    it("should have a correct hash after 3 inserts", async () => {
        const smt = new SparseMerkleTree(2);
        smt.insert("5");
        smt.insert("6");
        smt.insert("7");
        const h11 = mimc2("5", "6");
        const h12 = mimc2("7", "0");
        const h2 = mimc2(h11, h12);
        smt.should.have.property('digest', h2);
    });

    it("should give correct paths after 3 inserts", async () => {
        const smt = new SparseMerkleTree(2);
        smt.insert("5");
        smt.insert("6");
        smt.insert("7");
        const h11 = mimc2("5", "6");
        const h12 = mimc2("7", "0");
        const h2 = mimc2(h11, h12);
        smt.path("5").should.be.deep.equal([["6", false], [h12, false]]);
        smt.path("6").should.be.deep.equal([["5",  true], [h12, false]]);
        smt.path("7").should.be.deep.equal([["0", false], [h11, true]]);
    });
});

describe("SparseMerkleTree(100)", () => {
    it("should be constructable", async () => {
        const smt = new SparseMerkleTree(100);
        smt.should.exist;
        smt.should.be.an.instanceof(SparseMerkleTree);
    });

    it("should have a correct hash when empty", async () => {
        const smt = new SparseMerkleTree(100);
        let hashes = ["0"];
        while (hashes.length <= 100) {
            const last = hashes[hashes.length - 1];
            hashes.push(mimc2(last, last));
        }
        smt.should.have.property('digest', hashes[hashes.length - 1]);
    });

    it("should have a correct hash after one insert", async () => {
        const smt = new SparseMerkleTree(100);
        let hashes = ["0"];
        let acc = "5";
        while (hashes.length <= 100) {
            const last = hashes[hashes.length - 1];
            acc = mimc2(acc, last);
            hashes.push(mimc2(last, last));
        }
        smt.insert("5");
        smt.should.have.property('digest', acc);
    });

    it("should give a correct path after one insert", async () => {
        const smt = new SparseMerkleTree(100);
        let hashes = ["0"];
        let acc = "15";
        let path = [];
        while (hashes.length <= 100) {
            const last = hashes[hashes.length - 1];
            acc = mimc2(acc, last);
            hashes.push(mimc2(last, last));
            path.push([last, false]);
        }
        smt.insert("15");
        smt.path("15").should.be.deep.equal(path);
    });
});
