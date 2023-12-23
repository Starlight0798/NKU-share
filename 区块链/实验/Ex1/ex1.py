from bitcoin.core.script import *

from utils import *
from config import (my_private_key, my_public_key, my_address,
                    faucet_address)


def P2PKH_scriptPubKey(address):
    ######################################################################
    # TODO: Complete the standard scriptPubKey implementation for a
    # PayToPublicKeyHash transaction
    # 使用 OP_DUP、OP_HASH160 和 OP_EQUALVERIFY 来创建 PayToPublicKeyHash 脚本
    # 将地址的哈希值添加到脚本中
    return [OP_DUP, OP_HASH160, address, OP_EQUALVERIFY, OP_CHECKSIG]
    ######################################################################


def P2PKH_scriptSig(txin, txout, txin_scriptPubKey):
    signature = create_OP_CHECKSIG_signature(txin, txout, txin_scriptPubKey,
                                             my_private_key)
    ######################################################################
    # TODO: Complete this script to unlock the BTC that was sent to you
    # in the PayToPublicKeyHash transaction. You may need to use variables
    # that are globally defined.
    # 返回包含签名和公钥的脚本
    return [signature, my_public_key]
    ######################################################################


def send_from_P2PKH_transaction(amount_to_send, txid_to_spend, utxo_index,
                                txout_scriptPubKey):
    txout = create_txout(amount_to_send, txout_scriptPubKey)

    txin_scriptPubKey = P2PKH_scriptPubKey(my_address)
    txin = create_txin(txid_to_spend, utxo_index)
    txin_scriptSig = P2PKH_scriptSig(txin, txout, txin_scriptPubKey)

    new_tx = create_signed_transaction(txin, txout, txin_scriptPubKey,
                                       txin_scriptSig)

    return broadcast_transaction(new_tx)


if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.0005
    txid_to_spend = (
        '0f9e86805172a59753705e6d520485f3f3cc0f8e1996d34a0abfad76dde94df5')
    utxo_index = 1
    ######################################################################

    txout_scriptPubKey = P2PKH_scriptPubKey(faucet_address)
    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index, txout_scriptPubKey)
    print(response.status_code, response.reason)
    print(response.text)

'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "8cdba4eb2869a3f8573e33467b94a276602ca171c913f00339e06d9050e44338",
    "addresses": [
      "mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB",
      "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
    ],
    "total": 50000,
    "fees": 50000,
    "size": 192,
    "vsize": 192,
    "preference": "high",
    "relayed_by": "139.162.108.57",
    "received": "2023-09-18T11:30:08.55639076Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 1,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "0f9e86805172a59753705e6d520485f3f3cc0f8e1996d34a0abfad76dde94df5",
        "output_index": 1,
        "script": "483045022100c97998ac1e72f88aa851ba5f8f449826da2ac364425bc1780fb81094c9ce1c4b02205391142cb1434a5837108adf138814507ff93dab05aa2759c12a85cdecb02948012103389c39b1635b32119096ce8020862ae2d98bde073572af3201de77ce3ab90553",
        "output_value": 100000,
        "sequence": 4294967295,
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash",
        "age": 2503320
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