from sys import exit
from bitcoin.core.script import *

from utils import *
from config import my_private_key, my_public_key, my_address, faucet_address
from ex1 import P2PKH_scriptPubKey
from ex2a import (ex2a_txout_scriptPubKey, cust1_private_key, cust2_private_key,
                  cust3_private_key)


def multisig_scriptSig(txin, txout, txin_scriptPubKey):
    bank_sig = create_OP_CHECKSIG_signature(txin, txout, txin_scriptPubKey,
                                             my_private_key)
    cust1_sig = create_OP_CHECKSIG_signature(txin, txout, txin_scriptPubKey,
                                             cust1_private_key)
    cust2_sig = create_OP_CHECKSIG_signature(txin, txout, txin_scriptPubKey,
                                             cust2_private_key)
    cust3_sig = create_OP_CHECKSIG_signature(txin, txout, txin_scriptPubKey,
                                             cust3_private_key)
    ######################################################################
    # TODO: Complete this script to unlock the BTC that was locked in the
    # multisig transaction created in Exercise 2a.
    scriptSig = [OP_0, cust3_sig, bank_sig]
    return scriptSig
    ######################################################################


def send_from_multisig_transaction(amount_to_send, txid_to_spend, utxo_index,
                                   txin_scriptPubKey, txout_scriptPubKey):
    txout = create_txout(amount_to_send, txout_scriptPubKey)

    txin = create_txin(txid_to_spend, utxo_index)
    txin_scriptSig = multisig_scriptSig(txin, txout, txin_scriptPubKey)

    new_tx = create_signed_transaction(txin, txout, txin_scriptPubKey,
                                       txin_scriptSig)

    return broadcast_transaction(new_tx)

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.0001
    txid_to_spend = '2050446550037a248db121a2229dad554a6465bdb0ce3c7a4cb54197b98330b7'
    utxo_index = 0
    ######################################################################

    txin_scriptPubKey = ex2a_txout_scriptPubKey
    txout_scriptPubKey = P2PKH_scriptPubKey(faucet_address)

    response = send_from_multisig_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        txin_scriptPubKey, txout_scriptPubKey)
    print(response.status_code, response.reason)
    print(response.text)
    
    
'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "0fc5e7c22ec2fa7d42f72512557a06df753f371dbc6b45a786d4906e80573d08",
    "addresses": [
      "zNSU7nqXLgFtYU2Uvnfsh2s7SzSnDmtHM2",
      "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
    ],
    "total": 10000,
    "fees": 90000,
    "size": 231,
    "vsize": 231,
    "preference": "high",
    "relayed_by": "172.104.103.203",
    "received": "2023-10-07T01:11:57.000030986Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 1,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "2050446550037a248db121a2229dad554a6465bdb0ce3c7a4cb54197b98330b7",
        "output_index": 0,
        "script": "00483045022100f75dab12c26c5cd800300edb7f59bb01513ca7d08e1d9d2f99d6f34086f6dd5a02205432e43d85038cb854740a8e609e252b373023a6e4e1841be73ed632eb0bf904014730440220681fec1368ef2cb6fcbe70c7835c388ebd65ab8ba5433f6965c7df016f9eb58d0220325478cf35ad4c5c1786133eb6e0df7a21aa939fbc3950454d7b54498e2a0a1b01",
        "output_value": 100000,
        "sequence": 4294967295,
        "addresses": [
          "zNSU7nqXLgFtYU2Uvnfsh2s7SzSnDmtHM2"
        ],
        "script_type": "pay-to-multi-pubkey-hash",
        "age": 2530778
      }
    ],
    "outputs": [
      {
        "value": 10000,
        "script": "76a9149f9a7abd600c0caa03983a77c8c3df8e062cb2fa88ac",
        "addresses": [
          "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
        ],
        "script_type": "pay-to-pubkey-hash"
      }
    ]
  }
}
'''
