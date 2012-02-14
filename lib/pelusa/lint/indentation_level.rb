module Pelusa
  module Lint
    class IndentationLevel
      def initialize
        @violations = Set.new
      end

      def check(klass)
        initialize
        iterate_lines!(klass)
        if @violations.empty?
          SuccessfulAnalysis.new(name)
        else
          FailedAnalysis.new(name, @violations) do |violations|
            "There's too much indentation in lines #{violations.to_a.join(', ')}."
          end
        end
      end

      private

      def name
        "Doesn't use more than one indentation level inside methods"
      end

      def iterate_lines!(klass)
        iterator = Iterator.new do |node|
          if node.is_a?(Rubinius::AST::Define)
            _iterate = Iterator.new do |node|
              __iterate = Iterator.new do |node|
                if body = get_body_from_node[node]
                  if node.line != [body].flatten.first.line
                    @violations << body.line
                  end
                end
              end

              Array(get_body_from_node[node]).each(&__iterate)
            end
            node.body.array.each(&_iterate)
          end
        end

        Array(klass).each(&iterator)
      end

      def get_body_from_node
        lambda do |node|
          if node.respond_to?(:body) && !node.body.is_a?(Rubinius::AST::NilLiteral)
             node.body
          elsif node.respond_to?(:else)
             node.else
          end
        end
      end
    end
  end
end
    def check_indentation_levels!
      violations = Set.new

      get_body_from_node = lambda do |node|
        if node.respond_to?(:body) && !node.body.is_a?(Rubinius::AST::NilLiteral)
           node.body
        elsif node.respond_to?(:else)
           node.else
        end
      end

      iterate = self.class.iterator do |node|
        if node.is_a?(Rubinius::AST::Define)
          _iterate = self.class.iterator do |node|
            __iterate = self.class.iterator do |node|
              if body = get_body_from_node[node]
                if node.line != [body].flatten.first.line
                  violations << body.line
                end
              end
            end

            Array(get_body_from_node[node]).each(&__iterate)
          end
          node.body.array.each(&_iterate)
        end
      end

      report "Doesn't use more than one indentation level" do
        Array(ast).each(&iterate)
        if violations.empty?
          Report.new
        else
          Report.new(violations) { |violations| "There's too much of indentation at lines #{violations.to_a.join(', ')}." }
        end
      end
    end
