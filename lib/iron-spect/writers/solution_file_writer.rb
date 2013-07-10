module IronSpect
  module Writers

    class SolutionFileWriter

      def initialize(parsed_sln)
        @parsed_sln = parsed_sln
      end

      def write(directory, name)
        file = File.open("#{directory}/#{name}.sln", 'w')
        file.write("#{version[:sln_type]} Solution File, Format Version #{version[:sln_version]}\n")
        projects.each do |project|
          file.write("project(\"#{project[:guid]}\") = \"#{project[:assembly_info][:name]}\", \"#{project[:assembly_info][:path]}\", \"#{project[:assembly_info][:guid]}\"\nEndProject\n")
        end
        file.write("Global\n")
        globals.each do |global|
          file.write("\tGlobalSection(#{global[:property_tag]}) = #{global[:property_step]}\n")
          global[:properties].each do |property|
            file.write("\t\t#{property[:key]} = #{property[:value]}\n")
          end
          file.write("\tEndGlobalSection\n")
        end
        file.write('EndGlobal')
      end

      private

      def version
        @parsed_sln[:version_info]
      end

      def projects
        @parsed_sln[:projects]
      end

      def globals
        @parsed_sln[:global]
      end
    end
  end
end