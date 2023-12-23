from bitcoin.core.script import *

from utils import *
from config import (my_private_key, my_public_key, my_address,
                    faucet_address)


def split_coins(amount_to_send, txid_to_spend, utxo_index, n):
    txin_scriptPubKey = my_address.to_scriptPubKey()
    txin = create_txin(txid_to_spend, utxo_index)
    txout_scriptPubKey = my_address.to_scriptPubKey()
    txout = create_txout(amount_to_send / n, txout_scriptPubKey)
    tx = CMutableTransaction([txin], [txout]*n)
    sighash = SignatureHash(txin_scriptPubKey, tx,
                            0, SIGHASH_ALL)
    txin.scriptSig = CScript([my_private_key.sign(sighash) + bytes([SIGHASH_ALL]),
                              my_public_key])
    VerifyScript(txin.scriptSig, txin_scriptPubKey,
                 tx, 0, (SCRIPT_VERIFY_P2SH,))
    response = broadcast_transaction(tx)
    print(response.status_code, response.reason)
    print(response.text)

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.003 # amount of BTC in the output you're splitting minus fee
    txid_to_spend = (
        '1d0dfb11993bae5e1946f1b5e4cb027e4df623b452296e32fd036790831907d7')
    utxo_index = 0
    n=3 # number of outputs to split the input into
    ######################################################################

    split_coins(amount_to_send, txid_to_spend, utxo_index, n)
    
    
'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "0f9e86805172a59753705e6d520485f3f3cc0f8e1996d34a0abfad76dde94df5",
    "addresses": [
      "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
    ],
    "total": 300000,
    "fees": 798115,
    "size": 259,
    "vsize": 259,
    "preference": "high",
    "relayed_by": "172.105.223.27",
    "received": "2023-09-18T00:06:34.585744909Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 3,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "1d0dfb11993bae5e1946f1b5e4cb027e4df623b452296e32fd036790831907d7",
        "output_index": 0,
        "script": "473044022069fc8474fc2cee01cfa9492d9bd88218ae03cd1bd250ae9e9238897c3b90b4b0022076d3f02ee6608f889b02dacb3d77d9a194315058387eb0118f1ea99644a0b712012103389c39b1635b32119096ce8020862ae2d98bde073572af3201de77ce3ab90553",     
        "output_value": 1098115,
        "sequence": 4294967295,
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash",
        "age": 0
      }
    ],
    "outputs": [
      {
        "value": 100000,
        "script": "76a914da847c3ad8729e8ab3d6ca12f9097b9f8c0e141a88ac",
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash"
      },
      {
        "value": 100000,
        "script": "76a914da847c3ad8729e8ab3d6ca12f9097b9f8c0e141a88ac",
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash"
      },
      {
        "value": 100000,
        "script": "76a914da847c3ad8729e8ab3d6ca12f9097b9f8c0e141a88ac",
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash"
      }
    ]
  }
}
'''
