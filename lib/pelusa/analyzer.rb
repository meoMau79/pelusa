module Pelusa
  class Analyzer
    # Public: Initializes an Analyzer.
    #
    # ast      - The abstract syntax tree to analyze.
    # reporter - The class that will be used to create the report.
    # filename - The name of the file that we're analyzing.
    def initialize(lints, reporter, filename)
      @lints    = lints
      @reporter = reporter.new(filename)
    end

    # Public: Makes a report out of several classes contained in the AST.
    #
    # ast - The abstract syntax tree to analyze.
    #
    # Returns a Report of all the classes.
    def analyze(ast)
      reports = extract_classes(ast).map do |klass|
        class_analyzer = ClassAnalyzer.new(klass)
        class_name     = class_analyzer.class_name
        analysis       = class_analyzer.analyze(@lints)

        Report.new(class_name, analysis)
      end
      @reporter.reports = reports
      @reporter
    end

    #######
    private
    #######

    # Internal: Extracts the classes out of the AST and returns their nodes.
    #
    # ast - The abstract syntax tree to extract the classes from.
    #
    # Returns an Array of Class nodes.
    def extract_classes(ast)
      classes = []
      class_iterator = Iterator.new do |node|
        classes << node if node.is_a?(Rubinius::AST::Class)
      end
      Array(ast).each(&class_iterator)
      classes
    end
  end
end
