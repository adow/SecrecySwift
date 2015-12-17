#coding= utf-8
'''

by adow
'''
import os
import logging
import functools
import uuid
from string import Template
import time
import datetime
import json
import hashlib
import re
import base64
import urllib as urllib_parse

from Crypto.PublicKey import RSA
from Crypto.Hash import MD5
from Crypto.Hash import SHA
from Crypto.Cipher import AES
from Crypto import Random

# load_key
f = open('private.pem')
private_key_str = f.read()
f.close()
private_key = RSA.importKey(private_key_str)

f = open('public.pem')
public_key_str = f.read()
f.close()
public_key = RSA.importKey(public_key_str)

def _pkcs7padding(data):    
    """   
    对齐块   
    size 16   
    999999999=>9999999997777777   
    """    
    size = AES.block_size    
    count = size - len(data)%size    
    if count:    
        data+=(chr(count)*count)    
    return data

def test_rsa_decrypt():
    from Crypto.Cipher import PKCS1_v1_5
    '''测试 RSA 解密，从 SwcrecyDemo 中得到加密后的 base64 字符串'''
    encrypt_base64 = "fvuu1fKeeo3Z/qoSAsZ80IyTu+7BJ2OEfcGJAgnxaO6D82lsNp+QEYgSzTK7IgrUnHhqEFYWsqnGIlX5N/SDblZbBTTEXKHcWntlV3bVJQUUxK+GGC1j7GK02bL0yNZRZ1xz/JU9nZV2L7lt3PQckh0f1Lc2xBe7hqprbVYkufFVnE3hwPirVUyfbbhE8KZ2eiMTApxRY+GRHtpBhibPkZ44E4NDmNaT9S8uMjZ6TqTzQddp9MCGMo+6Kp4HA+O33LG9pgxAoAgm/J6NeJJB3iSdtMdQ6IyBnw2p93KaVlnD8kWg10BbxtJ0QWg7osiEoLXVWoLBzqARkk1pl+66FQ=="
    encrypt = base64.b64decode(encrypt_base64)
    cipher = PKCS1_v1_5.new(private_key)

    dsize = SHA.digest_size
    sentinel = Random.new().read(15 + dsize)
    decrypt = cipher.decrypt(encrypt,sentinel)
    print 'rsa_decrypt:%s'%(decrypt,)

def test_rsa_sign():
    from Crypto.Signature import PKCS1_v1_5
    raw = "0123456789abcdefg"
    digest = SHA.new(raw)

    verifier = PKCS1_v1_5.new(private_key)
    sign = verifier.sign(digest)
    sign_base64 = base64.b64encode(sign)
    print "sign:%s"%(sign_base64,)

def test_rsa_verify():
    from Crypto.Signature import PKCS1_v1_5
    raw = "0123456789abcdefg"
    digest = SHA.new(raw)
    sign_base64 = '''g/mL63vojOxMVMB/K4EeuG6VFg3smN/sd5zOrNZyBjYSXTELcmkzl7yqduSyBT/BvR6i3qeuyvb+lZ4osatXyZMe0q0dT0NiMNDfXAJ+awD8+5/SymKsPs0lrQXBjNhuCLbwC4Up5ueg5Whox3hRG2iMkN50y37wLYTqSWyYJ6RpvdsXNks2051m5pohCoD2OB97qEteqri0BqYfgmXh0Xq9weCtfdAbs20w2vp+wdFFqduu01ElGQtbkCuTokMzr5O9WWl8F7dKq1j7nXpdxKD9SFfQafUNSarET3qw2VC/Jck9u0q6sOZErb03fl034t5GeYKPtPIwBvzCGSsFsA=='''
    #print sign_base64
    sign = base64.b64decode(sign_base64)
    #verifier = PKCS1_v1_5.new(public_key)
    verifier = PKCS1_v1_5.new(public_key)
    v = verifier.verify(digest,sign)
    print "verifiy:%s"%(str(v),)

def test_aes_encrypt():
    raw = "0123456789abcdef"
    #raw = "012345678"
    raw = _pkcs7padding(raw)
    key = "0000000000000000"
    cipher = AES.new(key,AES.MODE_ECB)
    encrypt = cipher.encrypt(raw)
    encrypt_base64 = base64.b64encode(encrypt)
    print 'encrypt:%s'%(encrypt_base64,)

    iv = '0' * (AES.block_size)
    #print iv
    cipher = AES.new(key,AES.MODE_CBC,iv)
    encrypt = cipher.encrypt(raw)
    encrypt_base64 = base64.b64encode(encrypt)
    print 'encrypt:%s'%(encrypt_base64,)

def test_aes_decrypt():
    encrypt_base64 = "8dL/6Vu+D81gqcXzLXGl1TRrzguO7TTaEPao+ruERJQ="
    encrypt = base64.b64decode(encrypt_base64)
    key = "0000000000000000"
    cipher = AES.new(key,AES.MODE_ECB)
    raw = cipher.decrypt(encrypt)
    print 'decrypt:%s'%(raw,)
    


if __name__ == '__main__':
    test_rsa_decrypt()
    test_rsa_sign()
    test_rsa_verify()
    test_aes_encrypt()
    test_aes_decrypt()
