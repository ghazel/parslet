
require 'parslet/atoms/transform'

class Parslet::Optimizer < Parslet::Atoms::Transform
  
  def initialize
    super
    
    @current_optimisation = []
  end

  class ReturnFalseVisitor
  end
  
  class StringSeqVisitor
    def initialize
      @string = ''
    end
    
    def str
      Parslet.str(@string)
    end
    
    def visit_str(str)
      @string << str
      true
    end
  end
  
  # Sequence optimisation: Tries to conflate sequences into single complex
  # atoms. 
  #
  # Implemented optimisations:
  # * string concatenation
  #
  def visit_sequence(seq)
    # Transform all children
    transformed = seq.map { |e| e.accept(self) }
    
    # Is transformed just strings?
    v = StringSeqVisitor.new
    return v.str if transformed.all? { |e| e.accept(v) }
    
    # Classical result, just create another sequence
    foldr(transformed, &:>>)
  end
    
private
  def foldr(ary)
    return ary.dup if ary.size == 1
    ary[1..-1].inject(ary[0])
  end
end