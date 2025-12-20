-- | Encrypting and decrypting data, such as save data, with a passphrase.
module Network.Tox.C.EncryptSave
    ( toxPassEncrypt
    , toxPassDecrypt
    , toxPassKeyDerive
    , toxPassKeyDeriveWithSalt
    , toxPassKeyEncrypt
    , toxPassKeyDecrypt
    , toxGetSalt
    , toxIsDataEncrypted
    ) where

import           Data.ByteString         (ByteString)
import qualified Data.ByteString         as BS
import qualified FFI.Tox.EncryptSave     as Raw
import           Foreign.C.Enum          (callErrFun)
import           Foreign.ForeignPtr      (newForeignPtr, withForeignPtr)
import           Foreign.Marshal.Utils   (toBool)
import           Network.Tox.C.Constants (toxPassEncryptionExtraLength)
import           Network.Tox.C.Marshal   (getBytesErr, getFixedBytesErr,
                                          withBytesLen, withFixedBytes,
                                          withSizedBytes)
import           Network.Tox.C.Types     (ErrDecryption, ErrEncryption,
                                          ErrGetSalt, ErrKeyDerivation,
                                          PassKey (..), PassSalt)

-- | Encrypts the given data with the given passphrase.
--
-- The output array must be at least @plaintext_len +
-- TOX_PASS_ENCRYPTION_EXTRA_LENGTH@ bytes long. This delegates to
-- 'toxPassKeyDerive' and 'toxPassKeyEncrypt'.
--
-- * @plaintext@: A byte array of length @plaintext_len@.
-- * @passphrase@: The user-provided password. Can be empty.
toxPassEncrypt
    :: ByteString -> ByteString -> IO (Either ErrEncryption ByteString)
toxPassEncrypt plaintext passphrase =
    withBytesLen plaintext $ \plaintextPtr plaintextLen ->
    withBytesLen passphrase $ \passphrasePtr passphraseLen ->
        getBytesErr
            (BS.length plaintext + toxPassEncryptionExtraLength)
            (Raw.tox_pass_encrypt plaintextPtr plaintextLen passphrasePtr
                passphraseLen)

-- | Decrypts the given data with the given passphrase.
--
-- The output array must be at least @ciphertext_len -
-- TOX_PASS_ENCRYPTION_EXTRA_LENGTH@ bytes long. This delegates to
-- 'toxPassKeyDecrypt'.
--
-- * @ciphertext@: A byte array of length @ciphertext_len@.
-- * @passphrase@: The user-provided password. Can be empty.
toxPassDecrypt
    :: ByteString -> ByteString -> IO (Either ErrDecryption ByteString)
toxPassDecrypt ciphertext passphrase =
    withBytesLen ciphertext $ \ciphertextPtr ciphertextLen ->
    withBytesLen passphrase $ \passphrasePtr passphraseLen ->
        getBytesErr
            (BS.length ciphertext - toxPassEncryptionExtraLength)
            (Raw.tox_pass_decrypt ciphertextPtr ciphertextLen passphrasePtr
                passphraseLen)

-- | Generates a secret symmetric key from the given passphrase.
--
-- Be sure to not compromise the key! Only keep it in memory, do not write it
-- to disk.
--
-- Note that this function is not deterministic; to derive the same key from a
-- password, you also must know the random salt that was used. A deterministic
-- version of this function is 'toxPassKeyDeriveWithSalt'.
--
-- * @passphrase@: The user-provided password. Can be empty.
toxPassKeyDerive :: ByteString -> IO (Either ErrKeyDerivation PassKey)
toxPassKeyDerive passphrase =
    withBytesLen passphrase $ \passphrasePtr passphraseLen ->
        callErrFun (Raw.tox_pass_key_derive passphrasePtr passphraseLen)
            >>= traverse (fmap PassKey . newForeignPtr Raw.p_tox_pass_key_free)

-- | Same as above, except use the given salt for deterministic key derivation.
--
-- * @passphrase@: The user-provided password. Can be empty.
-- * @salt@: An array of exactly 'Network.Tox.C.Constants.toxPassSaltLength'
--   bytes.
toxPassKeyDeriveWithSalt
    :: ByteString -> PassSalt -> IO (Either ErrKeyDerivation PassKey)
toxPassKeyDeriveWithSalt passphrase salt =
    withBytesLen passphrase $ \passphrasePtr passphraseLen ->
    withFixedBytes salt $ \saltPtr ->
        callErrFun
            (Raw.tox_pass_key_derive_with_salt passphrasePtr passphraseLen
                saltPtr)
            >>= traverse (fmap PassKey . newForeignPtr Raw.p_tox_pass_key_free)

-- | Encrypt a plain text with a key produced by 'toxPassKeyDerive' or
-- 'toxPassKeyDeriveWithSalt'.
--
-- The output array must be at least @plaintext_len +
-- TOX_PASS_ENCRYPTION_EXTRA_LENGTH@ bytes long.
--
-- * @plaintext@: A byte array of length @plaintext_len@.
toxPassKeyEncrypt
    :: PassKey -> ByteString -> IO (Either ErrEncryption ByteString)
toxPassKeyEncrypt (PassKey key) plaintext =
    withForeignPtr key $ \keyPtr ->
    withBytesLen plaintext $ \plaintextPtr plaintextLen ->
        getBytesErr
            (BS.length plaintext + toxPassEncryptionExtraLength)
            (Raw.tox_pass_key_encrypt keyPtr plaintextPtr plaintextLen)

-- | This is the inverse of 'toxPassKeyEncrypt', also using only keys produced
-- by 'toxPassKeyDerive' or 'toxPassKeyDeriveWithSalt'.
--
-- * @ciphertext@: A byte array of length @ciphertext_len@.
toxPassKeyDecrypt
    :: PassKey -> ByteString -> IO (Either ErrDecryption ByteString)
toxPassKeyDecrypt (PassKey key) ciphertext =
    withForeignPtr key $ \keyPtr ->
    withBytesLen ciphertext $ \ciphertextPtr ciphertextLen ->
        getBytesErr
            (BS.length ciphertext - toxPassEncryptionExtraLength)
            (Raw.tox_pass_key_decrypt keyPtr ciphertextPtr ciphertextLen)

-- | Retrieves the salt used to encrypt the given data.
--
-- The retrieved salt can then be passed to 'toxPassKeyDeriveWithSalt' to
-- produce the same key as was previously used. Any data encrypted with this
-- module can be used as input.
--
-- The cipher text must be at least
-- 'Network.Tox.C.Constants.toxPassEncryptionExtraLength' bytes in length. The
-- salt must be 'Network.Tox.C.Constants.toxPassSaltLength' bytes in length.
-- If the passed byte arrays are smaller than required, the behaviour is
-- undefined.
--
-- If the cipher text pointer or the salt is NULL, this function returns
-- false.
--
-- Success does not say anything about the validity of the data, only that
-- data of the appropriate size was copied.
--
-- * @ciphertext@: The encrypted data; at least
--   'Network.Tox.C.Constants.toxPassEncryptionExtraLength' bytes are read.
toxGetSalt :: ByteString -> IO (Either ErrGetSalt PassSalt)
toxGetSalt ciphertext =
    withSizedBytes "ciphertext" ciphertext
        toxPassEncryptionExtraLength $ \ciphertextPtr ->
        getFixedBytesErr $ Raw.tox_get_salt ciphertextPtr

-- | Determines whether or not the given data is encrypted by this module.
--
-- It does this check by verifying that the magic number is the one put in
-- place by the encryption functions.
--
-- The data must be at least
-- 'Network.Tox.C.Constants.toxPassEncryptionExtraLength' bytes in length. If
-- the passed byte array is smaller than required, the behaviour is undefined.
--
-- If the data pointer is NULL, the behaviour is undefined
--
-- * @data'@: The data to check; at least
--   'Network.Tox.C.Constants.toxPassEncryptionExtraLength' bytes are read.
toxIsDataEncrypted :: ByteString -> IO Bool
toxIsDataEncrypted data' =
    withSizedBytes "data" data' toxPassEncryptionExtraLength $ \dataPtr ->
        toBool <$> Raw.tox_is_data_encrypted dataPtr
