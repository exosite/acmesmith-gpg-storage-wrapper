require 'acmesmith-gpg-storage-wrapper/version'
require 'acmesmith/storages/base'
require 'acmesmith/storages'
require 'acmesmith/account_key'
require 'gpgme'
module Acmesmith
  module Storages

    class GPGEngine

      def initialize(recipients: nil)
        @crypto = ::GPGME::Crypto.new
        @crypto_opt = {recipients: recipients}
      end

      def encrypt(plaintext)
        data = ::GPGME::Data.new(plaintext)
        @crypto.encrypt(data, @crypto_opt).to_s
      end

      def decrypt(ciphertext)
        data = ::GPGME::Data.new(ciphertext)
        @crypto.decrypt(data, @crypto_opt).to_s
      end

    end

    class AccountKeyGPGWrapper < AccountKey
      def self.setup(engine)
        Acmesmith.const_set(:AccountKey, self)
        @@engine = engine
      end

      def initialize(private_key, passphrase = nil)
        case private_key
        when String
          begin
          decrypted_key = @@engine.decrypt(private_key)
          rescue GPGME::Error::NoData
            super(private_key, passphrase)
          else
            super(decrypted_key, passphrase)
          end
        when ::OpenSSL::PKey
          super
        else
          super
        end
      end

    end

    class GpgStorageWrapper < Base
      attr_reader :storage, :engine

      def initialize(recipients: nil, storage: nil, **kwargs)
        wrappedStorageKlass = ::Acmesmith::Storages.find(storage)
        @storage = wrappedStorageKlass.new(**kwargs)
        @engine = GPGEngine.new(recipients: recipients)
      end

      def get_account_key
        raise NotImplementedError
      end

      def put_account_key(key, passphrase = nil)
        raise NotImplementedError
      end

      def put_certificate(cert, passphrase = nil, update_current: true)
        raise NotImplementedError
      end

      def get_certificate(common_name, version: 'current')
        raise NotImplementedError
      end

      def list_certificates
        raise NotImplementedError
      end

      def list_certificate_versions(common_name)
        raise NotImplementedError
      end

      def get_current_certificate_version(common_name)
        raise NotImplementedError
      end
    end
  end
end
