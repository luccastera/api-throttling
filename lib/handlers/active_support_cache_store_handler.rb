module Handlers
  class ActiveSupportCacheStoreHandler < Handler

    def initialize(object=nil)
      raise "Must provide an existing ActiveSupport::Cache::Store" unless object.is_a?(ActiveSupport::Cache::Store)
      @cache = object
    end

    def increment(key)
      @cache.write(key, (get(key)||0).to_i+1)
    end

    def get(key)
      @cache.read(key)
    end

    %w(MemCacheStore FileStore MemoryStore SynchronizedMemoryStore DRbStore CompressedMemCacheStore).each do |store|
      Handlers.add_handler(self, "ActiveSupport::Cache::#{store}".downcase)
    end
  end
end
