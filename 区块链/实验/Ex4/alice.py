from bitcoin.core import Hash160, CMutableTransaction,b2lx
from bitcoin.core.script import CScript, SignatureHash, SIGHASH_ALL
from bitcoin.core.scripteval import VerifyScript, SCRIPT_VERIFY_P2SH
from utils import create_txin, create_txout, create_OP_CHECKSIG_signature, create_signed_transaction, broadcast_transaction
from p2pkh import P2PKH_scriptPubKey, P2PKH_scriptSig

from swap_scripts import coinExchangeScript, coinExchangeScriptSig1, coinExchangeScriptSig2
from keys import (alice_secret_key_BTC, alice_public_key_BTC, alice_address_BTC, bob_public_key_BTC, bob_address_BTC,
                  alice_secret_key_BCY, alice_public_key_BCY, alice_address_BCY, bob_public_key_BCY, bob_address_BCY)

#############################################################################
# Alice wants to exchange her BTC in Testnet3 with Bob's BTC in BCY Testnet #
#############################################################################

alice_secret_x = "thisIsASecretPassword123".encode('utf-8')

def hash_of_secret():
    return Hash160(alice_secret_x)

def alice_swap_tx(txid_to_spend, utxo_index, amount_to_send):
    txout_script = coinExchangeScript(alice_public_key_BTC, bob_public_key_BTC, hash_of_secret())
    txout = create_txout(amount_to_send, txout_script)

    txin_scriptPubKey = P2PKH_scriptPubKey(alice_address_BTC)
    txin = create_txin(txid_to_spend, utxo_index)
    txin_scriptSig = P2PKH_scriptSig(txin, txout, txin_scriptPubKey,
        alice_secret_key_BTC, alice_public_key_BTC)
    
    tx = create_signed_transaction(txin, txout, txin_scriptPubKey,
                              txin_scriptSig)
    print('Alice swap tx (BTC) created successfully!')
    return tx, txout_script

def return_coins_tx(amount_to_send, last_tx, lock_time, script):
    txin = create_txin(b2lx(last_tx.GetTxid()), 0)
    txout = create_txout(amount_to_send, P2PKH_scriptPubKey(alice_address_BTC))
    tx = CMutableTransaction([txin], [txout], nLockTime=lock_time)
    return tx

def complete_return_tx(return_coins_tx, txin_scriptPubKey, bob_signature_BTC):
    alice_signature_BTC = sign_BTC(return_coins_tx, txin_scriptPubKey)
    txin = return_coins_tx.vin[0]
    txin.scriptSig = CScript(coinExchangeScriptSig2(alice_signature_BTC, bob_signature_BTC))
    VerifyScript(txin.scriptSig, CScript(txin_scriptPubKey),
                 return_coins_tx, 0, (SCRIPT_VERIFY_P2SH,))

    print('Alice return coins tx (BTC) created successfully!')
    return return_coins_tx

def redeem_swap(amount_to_send, bob_swap_tx, txin_scriptPubKey):
    txout_script = P2PKH_scriptPubKey(alice_address_BCY)
    txout = create_txout(amount_to_send, txout_script)

    txin = create_txin(b2lx(bob_swap_tx.GetTxid()), 0)
    tx = CMutableTransaction([txin], [txout])
    alice_signature_BCY = sign_BCY(tx, txin_scriptPubKey)
    txin_scriptSig = coinExchangeScriptSig1(alice_signature_BCY, alice_secret_x)
    txin.scriptSig = CScript(txin_scriptSig)
    VerifyScript(txin.scriptSig, CScript(txin_scriptPubKey),
                 tx, 0, (SCRIPT_VERIFY_P2SH,))

    print('Alice redeem from swap tx (BCY) created successfully!')
    return tx, alice_secret_x

def sign_BTC(tx, txin_scriptPubKey):
    sighash = SignatureHash(CScript(txin_scriptPubKey), tx,
                            0, SIGHASH_ALL)
    sig = alice_secret_key_BTC.sign(sighash) + bytes([SIGHASH_ALL])
    return sig

def sign_BCY(tx, txin_scriptPubKey):
    sighash = SignatureHash(CScript(txin_scriptPubKey), tx,
                            0, SIGHASH_ALL)
    sig = alice_secret_key_BCY.sign(sighash) + bytes([SIGHASH_ALL])
    return sig

def broadcast_BTC(tx):
    response = broadcast_transaction(tx, 'btc-test3')
    print(response.status_code, response.reason)
    print(response.text)

def broadcast_BCY(tx):
    response = broadcast_transaction(tx, 'bcy-test')
    print(response.status_code, response.reason)
    print(response.text)
