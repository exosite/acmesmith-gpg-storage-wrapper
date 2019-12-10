require "test_helper"
require "acmesmith/storages/filesystem"

class AcmesmithGpgStorageWrapperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::AcmesmithGpgStorageWrapper::VERSION
  end

  def test_it_can_be_inited_with_recipentts_and_filesystem_storage
    Acmesmith::Storages::GpgStorageWrapper.new(recipients:["a","b"], storage: "filesystem", path: "./storage")
  end

  def test_it_can_init_a_fs_store_with_path_param
    wrapper = Acmesmith::Storages::GpgStorageWrapper.new(recipients:["a","b"], storage: "filesystem", path: "./storage")
    assert wrapper.storage.is_a? ::Acmesmith::Storages::Filesystem
  end

  def test_it_can_encrypt_then_decrypt_data
    wrapper = Acmesmith::Storages::GpgStorageWrapper.new(recipients:["DDA11728"], storage: "filesystem", path: "./storage")
    data = "hello world"
    assert wrapper.engine.decrypt(wrapper.engine.encrypt(data)).to_s == data
  end

  def test_it_can_read_and_write_account_key
    path = "./test/tmp/storage"
    wrapper = Acmesmith::Storages::GpgStorageWrapper.new(recipients:["DDA11728"], storage: "filesystem", path: path)
    account_key = Acmesmith::AccountKey.generate
    wrapper.put_account_key(account_key)
    fetched_key = wrapper.get_account_key
    assert account_key.private_key.export == fetched_key.private_key.export
    FileUtils.rm "#{path}/account.pem"
  end

end
