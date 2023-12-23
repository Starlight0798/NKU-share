from sys import exit
from bitcoin.core.script import *

from utils import *
from config import my_private_key, my_public_key, my_address, faucet_address
from ex1 import P2PKH_scriptPubKey
from ex3a import ex3a_txout_scriptPubKey


######################################################################
# TODO: set these parameters correctly
amount_to_send = 0.0005
txid_to_spend = 'aca1ab96912e4cb3f2bf11131dafeb37a04a64c4bc0dbbcba5ff6a8a1c2a839c'
utxo_index = 0
######################################################################

txin_scriptPubKey = ex3a_txout_scriptPubKey
######################################################################
# TODO: implement the scriptSig for redeeming the transaction created
# in  Exercise 3a.
txin_scriptSig = [2104, -1893]
######################################################################
txout_scriptPubKey = P2PKH_scriptPubKey(faucet_address)

response = send_from_custom_transaction(
    amount_to_send, txid_to_spend, utxo_index,
    txin_scriptPubKey, txin_scriptSig, txout_scriptPubKey)
print(response.status_code, response.reason)
print(response.text)

'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "9efae9939bb4f37b876c728495c925208cc79854037b7acb9a3d5dccacb64a5c",
    "addresses": [
      "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB"
    ],
    "total": 50000,
    "fees": 50000,
    "size": 91,
    "vsize": 91,
    "preference": "high",
    "relayed_by": "172.233.65.43",
    "received": "2023-10-16T07:09:29.358582398Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 1,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "aca1ab96912e4cb3f2bf11131dafeb37a04a64c4bc0dbbcba5ff6a8a1c2a839c",
        "output_index": 0,
        "script": "023808026587",
        "output_value": 100000,
        "sequence": 4294967295,
        "script_type": "unknown",
        "age": 0
      }
    ],
    "outputs": [
      {
        "value": 50000,
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