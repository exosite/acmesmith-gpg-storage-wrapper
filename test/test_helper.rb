$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "acmesmith/storages/gpg-storage-wrapper"

require "minitest/autorun"
require "minitest/mock"
require "pry-byebug"
