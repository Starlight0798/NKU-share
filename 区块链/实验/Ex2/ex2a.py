from sys import exit
from bitcoin.core.script import *

from utils import *
from config import my_private_key, my_public_key, my_address, faucet_address
from ex1 import send_from_P2PKH_transaction
from bitcoin.wallet import CBitcoinSecret

'''
Private key: cTPX3uER5NCBuaSa7uGmmiTkwmaaNoxUsb7Jqmeypgh1vgWRJSYB
Address: mwYrtavjVHTeFCPcCb3nyS8xBbYamhoTsw

Private key: cVMmWt9SHKs7AK2RX4Zkh3kcUDM5vZ5Rbw1V4gTrKTA8yY8vhZQ8
Address: mfaknPc16CqXqZiGXhyTUAmXxRsXfDHtu5

Private key: cSw8pzk5EXxLh7q4FRborXnfaAJPqrLQv99b9G8LxqjRvP25VDHr
Address: n36uuqtyA1ty9zVEYBakFFvhNGy4RYL8jY
'''

cust1_private_key = CBitcoinSecret(
    'cTPX3uER5NCBuaSa7uGmmiTkwmaaNoxUsb7Jqmeypgh1vgWRJSYB')
cust1_public_key = cust1_private_key.pub
cust2_private_key = CBitcoinSecret(
    'cVMmWt9SHKs7AK2RX4Zkh3kcUDM5vZ5Rbw1V4gTrKTA8yY8vhZQ8')
cust2_public_key = cust2_private_key.pub
cust3_private_key = CBitcoinSecret(
    'cSw8pzk5EXxLh7q4FRborXnfaAJPqrLQv99b9G8LxqjRvP25VDHr')
cust3_public_key = cust3_private_key.pub


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 2

# You can assume the role of the bank for the purposes of this problem
# and use my_public_key and my_private_key in lieu of bank_public_key and
# bank_private_key.

ex2a_txout_scriptPubKey = [
    my_public_key,  # 银行的公钥
    OP_CHECKSIGVERIFY,
    OP_1,  # 数字1
    cust1_public_key,  # 第一个客户的公钥
    cust2_public_key,  # 第二个客户的公钥
    cust3_public_key,  # 第三个客户的公钥
    OP_3,  # 数字3
    OP_CHECKMULTISIG  # 多重签名检查
]

######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.001
    txid_to_spend = (
        'fd1658cd8869b0af1d7061c82cc852b5a55ad12bd070e38167417c98eeef2c23')
    utxo_index = 1
    ######################################################################

    response = send_from_P2PKH_transaction(
        amount_to_send, txid_to_spend, utxo_index,
        ex2a_txout_scriptPubKey)
    print(response.status_code, response.reason)
    print(response.text)

'''
201 Created
{
  "tx": {
    "block_height": -1,
    "block_index": -1,
    "hash": "2050446550037a248db121a2229dad554a6465bdb0ce3c7a4cb54197b98330b7",
    "addresses": [
      "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s",
      "zNSU7nqXLgFtYU2Uvnfsh2s7SzSnDmtHM2"
    ],
    "total": 100000,
    "fees": 1660338,
    "size": 306,
    "vsize": 306,
    "preference": "high",
    "relayed_by": "172.104.103.203",
    "received": "2023-10-07T00:54:03.134722495Z",
    "ver": 1,
    "double_spend": false,
    "vin_sz": 1,
    "vout_sz": 1,
    "confirmations": 0,
    "inputs": [
      {
        "prev_hash": "fd1658cd8869b0af1d7061c82cc852b5a55ad12bd070e38167417c98eeef2c23",
        "output_index": 1,
        "script": "47304402206858175e92af34ae6e58bfe8fb5585e0ae7b5472f6474827a931e547555ece1802202247ef1ee89d936ae4fefae2d529a7954ca372269e04d2b38f6e58397e0026c3012103389c39b1635b32119096ce8020862ae2d98bde073572af3201de77ce3ab90553",
        "output_value": 1760338,
        "sequence": 4294967295,
        "addresses": [
          "n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s"
        ],
        "script_type": "pay-to-pubkey-hash",
        "age": 2530772
      }
    ],
    "outputs": [
      {
        "value": 100000,
        "script": "2103389c39b1635b32119096ce8020862ae2d98bde073572af3201de77ce3ab90553ad51210375d247242cd16dba7845abd1074dcb13b0ed20744a03e8c9b4db4ed11ec727f22102b1519ff9ef12251dbaec8411c78dd9f3cb547bd93545d98e8325fff7c99ea8ff2102c6f664e49b7b0bb27435a50b57bd85e2e859c40aec3cfbaec63134cd680831b153ae",
        "addresses": [
          "zNSU7nqXLgFtYU2Uvnfsh2s7SzSnDmtHM2"
        ],
        "script_type": "pay-to-multi-pubkey-hash"
      }
    ]
  }
}
'''