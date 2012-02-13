module Pelusa
  class Iterator
    NodeIterator = lambda do |node, check|
      check.call(node)

      if node.respond_to?(:each)
        node.each { |node| NodeIterator.call(node, check) }
      else
        node.instance_variables.
          map { |ivar| node.instance_variable_get(ivar) }.
          each { |node| NodeIterator.call(node, check) }
      end
    end

    # Public: Initializes a new Iterator with a particular lint check.
    #
    # lint - The lint block that yields a node to assert for particular
    # conditions in that node.
    def initialize(&lint)
      @iterator = lambda { |node| NodeIterator.call(node, lint) }
    end

    # Public: Calls the iterator with the given arguments.
    #
    # node - The root node from which to iterate.
    def call(node)
      @iterator.call(node)
    end

    # Public: Returns the iterator. Useful when using symbol to proc
    # conversions, such as &iterator.
    #
    # Returns the Proc iterator.
    def to_proc
      @iterator
    end
  end
end
