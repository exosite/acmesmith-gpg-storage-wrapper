require "test_helper"

class Acmesmith::Storage::GpgStorageWrapperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Acmesmith::Storage::GpgStorageWrapper::VERSION
  end

  def test_it_does_something_useful
    assert true
  end
end
