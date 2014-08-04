require 'keen-cli/version'
require 'keen-cli/cli'

require 'dotenv'

Dotenv.load

module KeenCli

end

class Hash

  def deep_merge(hash)
    target = dup
    hash.keys.each do |key|
      if hash[key].is_a? Hash and self[key].is_a? Hash
        target[key] = target[key].deep_merge(hash[key])
        next
      end
      target[key] = hash[key]
    end
    target
  end

end
