from sys import exit
from bitcoin.core.script import *

from utils import *
from config import my_private_key, my_public_key, my_address, faucet_address
from ex1 import send_from_P2PKH_transaction


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 3
ex3a_txout_scriptPubKey = [
    OP_2DUP,
    OP_ADD,
    211,
    OP_EQUALVERIFY,
    OP_SUB,
    3997,
    OP_EQUAL
]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.001
    txid_to_spend = (
        'f18883d9950943048f7acdda0c49014ce536ffd2903aeef22dca6d33cba17dbf')
    utxo_index = 1
    ######################################################################

    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        ex3a_txout_scriptPubKey)
    print(response.status_code, response.reason)
    print(response.text)

'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "aca1ab96912e4cb3f2bf11131dafeb37a04a64c4bc0dbbcba5ff6a8a1c2a839c",
    "addresses": [
      "mwYrtavjVHTeFCPcCb3nyS8xBbYamhoTsw"
    ],
    "total": 100000,
    "fees": 1222274,
    "size": 178,
    "vsize": 178,
    "preference": "high",
    "relayed_by": "172.233.65.43",
    "received": "2023-10-16T07:08:52.923318023Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 1,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "f18883d9950943048f7acdda0c49014ce536ffd2903aeef22dca6d33cba17dbf",
        "output_index": 1,
        "script": "483045022100f6a4881af31687e9242c158974302a3126aaab16d5905548847bc77b3d48c74602203f03eb180e5f0b71db297a98d91b4e73bc75b0ae2bdd09818978bee1550b610601210375d247242cd16dba7845abd1074dcb13b0ed20744a03e8c9b4db4ed11ec727f2",
        "output_value": 1322274,
        "sequence": 4294967295,
        "addresses": [
          "mwYrtavjVHTeFCPcCb3nyS8xBbYamhoTsw"
        ],
        "script_type": "pay-to-pubkey-hash",
        "age": 2533342
      }
    ],
    "outputs": [
      {
        "value": 100000,
        "script": "6e9302d3008894029d0f87",
        "addresses": null,
        "script_type": "unknown"
      }
    ]
  }
}
'''