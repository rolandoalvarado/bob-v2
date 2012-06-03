# Aliases for Cucumber's 'Then' keyword

def TestCase(regex, &block)
  Then regex, &block
end

def Step(regex, &block)
  Then regex, &block
end

# Aliases for Cucumber's steps metho

def Preconditions(str)
  steps str
end

def Cleanup(str)
  steps str
end

def Script(str)
  steps str
end