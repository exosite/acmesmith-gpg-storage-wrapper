require "test_helper"

class Acmesmith::Gpg::Storage::WrapperTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Acmesmith::Gpg::Storage::Wrapper::VERSION
  end

  def test_it_does_something_useful
    assert false
  end
end
