require 'acmesmith-gpg-storage-wrapper/version'
require 'acmesmith/storages/base'
require 'acmesmith/storages'
require 'acmesmith/account_key'
require 'acmesmith/certificate'
require 'gpgme'
module Acmesmith
  module Storages

    class GPGEngine

      def initialize(recipients: nil)
        @crypto = ::GPGME::Crypto.new(always_trust: true)
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

    class CertificateGPGWrapper < Certificate

      def self.setup(engine)
        Acmesmith.send(:remove_const, :Certificate) if Acmesmith.const_defined?(:Certificate)
        Acmesmith.const_set(:Certificate, self)
        @@engine = engine
      end

      def initialize(certificate, chain, private_key, key_passphrase=nil, csr=nil)
        if private_key.is_a? String
          begin
            private_key = @@engine.decrypt(private_key)
          rescue GPGME::Error::NoData
          end
        end
        super(certificate,chain,private_key,key_passphrase,csr)
      end

      def export(passphrase, cipher: OpenSSL::Cipher.new('aes-256-cbc'))
        h = super
        h[:private_key] = @@engine.encrypt(h[:private_key])
        h
      end

    end

    class AccountKeyGPGWrapper < AccountKey
      def self.setup(engine)
        Acmesmith.send(:remove_const, :AccountKey) if Acmesmith.const_defined?(:AccountKey)
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

      def export(passphrase, cipher:  OpenSSL::Cipher.new('aes-256-cbc'))
        if passphrase
          plaintext = private_key.export(cipher, passphrase)
        else
          plaintext = private_key.export
        end
        @@engine.encrypt(plaintext)
      end

    end

    class GpgStorageWrapper < Base
      attr_reader :storage, :engine

      def initialize(recipients: nil, storage: nil, **kwargs)
        wrappedStorageKlass = ::Acmesmith::Storages.find(storage)
        @storage = wrappedStorageKlass.new(**kwargs)
        @engine = GPGEngine.new(recipients: recipients)
        AccountKeyGPGWrapper.setup(@engine)
        CertificateGPGWrapper.setup(@engine)
      end

      def get_account_key
        @storage.get_account_key
      end

      def put_account_key(key, passphrase = nil)
        @storage.put_account_key(key, passphrase)
      end

      def put_certificate(cert, passphrase = nil, update_current: true)
        @storage.put_certificate(cert, passphrase, update_current: update_current)
      end

      def get_certificate(common_name, version: 'current')
        @storage.get_certificate(common_name, version: version)
      end

      def list_certificates
        @storage.list_certificates
      end

      def list_certificate_versions(common_name)
        @storage.list_certificate_versions(common_name)
      end

      def get_current_certificate_version(common_name)
        @storage.get_current_certificate_version(common_name)
      end
    end
  end
end
