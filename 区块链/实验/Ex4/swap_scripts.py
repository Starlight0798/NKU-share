from bitcoin.core.script import *

######################################################################
# This function will be used by Alice and Bob to send their respective
# coins to a utxo that is redeemable either of two cases:
# 1) Recipient provides x such that hash(x) = hash of secret 
#    and recipient signs the transaction.
# 2) Sender and recipient both sign transaction
# 
# TODO: Fill this in to create a script that is redeemable by both
#       of the above conditions.
# 
# See this page for opcode: https://en.bitcoin.it/wiki/Script
#
#

# This is the ScriptPubKey for the swap transaction
def coinExchangeScript(public_key_sender, public_key_recipient, hash_of_secret):
    return [
        # fill this in!
        #匹配是否包含接收的签名
        public_key_recipient,#接受者的公钥放入脚本当中
        OP_CHECKSIGVERIFY,#验证公钥是否有效
        #复制栈顶的元素，因为要进⾏两种判断
        OP_DUP,
        #检查是不是发送者的签名
        public_key_sender,
        OP_CHECKSIG,
        OP_IF,#如果发送者的签名有效，就执行OP_DROP，栈中移除一个元素
        OP_DROP,
        OP_1,#压栈1，代表True
        OP_ELSE,#如果不成立
        OP_HASH160,#计算提供秘密的哈希值
        hash_of_secret,
        OP_EQUAL,#比较秘密的哈希值
        OP_ENDIF
    ]

# This is the ScriptSig that the receiver will use to redeem coins
def coinExchangeScriptSig1(sig_recipient, secret):
    return [
        secret,#秘密
        sig_recipient,#接收者的签名
    ]

# This is the ScriptSig for sending coins back to the sender if unredeemed
def coinExchangeScriptSig2(sig_sender, sig_recipient):
    return [
        sig_sender,#发送者的签名
        sig_recipient,#接收者的签名
    ]

#
#
######################################################################

