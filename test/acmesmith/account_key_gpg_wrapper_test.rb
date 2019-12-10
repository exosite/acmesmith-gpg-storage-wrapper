require "test_helper"
require "acmesmith/storages/filesystem"
require "acmesmith/storages/gpgStorageWrapper"
require "acmesmith/account_key"

class AccountKeyGPGWrapperTest < Minitest::Test

  def test_setup_extends_account_key_with_wrapper
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    rsa_key = Acmesmith::AccountKey.generate.export(nil)
    account_key = Acmesmith::AccountKey.new(rsa_key)
    assert account_key.is_a? Acmesmith::Storages::AccountKeyGPGWrapper
  end

  def test_it_can_init_with_plain_rsa_key
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    rsa_key = Acmesmith::AccountKey.generate.private_key.export
    account_key = Acmesmith::AccountKey.new(rsa_key)
    assert account_key.private_key != nil
  end

  def test_it_can_handle_encrypted_gpg_data
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    encrypted_rsa_key = Acmesmith::AccountKey.generate.export(nil)
    account_key = Acmesmith::AccountKey.new(encrypted_rsa_key)
    assert account_key.private_key != nil
  end

  def test_it_can_decrypt_then_encrypt_key
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    encrypted_rsa_key = Acmesmith::AccountKey.generate.export(nil)
    account_key = Acmesmith::AccountKey.new(encrypted_rsa_key)
    rsa_key = account_key.private_key.export
    exported_encrypted_key = account_key.export(nil)
    assert engine.decrypt(exported_encrypted_key) == rsa_key
  end

end
