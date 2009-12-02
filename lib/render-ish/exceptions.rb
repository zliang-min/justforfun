module Renderish

  # Raised when templates cannot be found.
  class NoTemplateError < RuntimeError
    def initialize(template, options={})
      super("Template #{template} was not found, with options #{options.inspect}")
    end
  end

  # Raised when unregistered engines are used.
  class UnsupportedEngine < RuntimeError
    def initialize(engine)
      super "Engine #{engine} is not supported."
    end
  end

end
