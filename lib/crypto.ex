defmodule Crypto do
  def keypair do
    # %{public: public, secret: secret} = :enacl.crypto_sign_ed25519_keypair
    #
    # {
    #   public,
    #   secret,
    # }

    :libsodium_crypto_sign_ed25519.keypair()
  end

  def sign(message, secret_key) do
    # :enacl.sign_detached(data, secret_key)
    :libsodium_crypto_sign_ed25519.detached(message, secret_key)
  end

  def valid_signature?(signature, message, public_key) do
    # case :enacl.sign_verify_detached(signature, message, public_key) do
    #   {:ok, _data} -> true
    #   {:error, _message} -> false
    # end
    case :libsodium_crypto_sign_ed25519.verify_detached(signature, message, public_key) do
      0 -> true
      1 -> false
    end
  end

  def public_key_from_private_key(private_key) do
    :libsodium_crypto_sign_ed25519.sk_to_pk(private_key)
  end
end
