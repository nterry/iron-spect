require 'xmlsimple'

module IronSpect
  module Parsers
    class ProjectFileParser

      def initialize(csproj_file_path)
        raise "#{csproj_file_path} doesn't exist." if not File.exist?(csproj_file_path)
        @csproj_file_path = csproj_file_path
      end

      def parse
        XmlSimple.xml_in(@csproj_file_path)
      end
    end
  end
end