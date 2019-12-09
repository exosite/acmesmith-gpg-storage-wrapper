require "test_helper"
require "acmesmith/storages/filesystem"
require "acmesmith/storages/gpg-storage-wrapper"
require "acmesmith/account_key"

class AccountKeyGPGWrapperTest < Minitest::Test

  def test_setup_extends_account_key_with_wrapper
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    rsa_key = Acmesmith::AccountKey.generate.export(nil)
    account_key = Acmesmith::AccountKey.new(rsa_key)
    assert account_key.is_a? Acmesmith::Storages::AccountKeyGPGWrapper
  end

  def test_it_can_handle_encrypted_gpg_data
    engine = Acmesmith::Storages::GPGEngine.new(recipients: ["DDA11728"])
    Acmesmith::Storages::AccountKeyGPGWrapper.setup(engine)
    rsa_key = Acmesmith::AccountKey.generate.export(nil)
    encrypted_key = engine.encrypt(rsa_key)
    account_key = Acmesmith::AccountKey.new(encrypted_key)
    assert account_key.private_key != nil
  end

end
