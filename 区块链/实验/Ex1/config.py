from bitcoin import SelectParams
from bitcoin.base58 import decode
from bitcoin.wallet import CBitcoinAddress, CBitcoinSecret, P2PKHBitcoinAddress


SelectParams('testnet')

# TODO: Fill this in with your private key.
my_private_key = CBitcoinSecret(
    'cMgAQCETy1PB5o49wpRdCTYaQ5Mrqa2bHHrS2GorFkycgCZN1VFZ')
my_public_key = my_private_key.pub
my_address = P2PKHBitcoinAddress.from_pubkey(my_public_key)

# faucet_address = CBitcoinAddress('n1SNK7QJkoN6yPWPb4ZmNpRCkcQDTCg46s')
faucet_address = CBitcoinAddress('mv4rnyY3Su5gjcDNzbMLKBQkBicCtHUtFB')
