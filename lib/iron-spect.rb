require_relative 'iron-spect/version'
require_relative '../lib/iron-spect/parsers/solution_file_parser'
require_relative '../lib/iron-spect/parsers/project_file_parser'

module IronSpect
  class Inspecter

    def initialize(repo_dir=Dir.getwd)
      @sln_file_manager = Parsers::SolutionFileParser.new(repo_dir)
      @sln_file = @sln_file_manager.parse
      @repo_dir = repo_dir
      #TODO: This is not correct, I need to either set the @startup_csproj_file variable to be a project object, or find a way to get the path (i.e. as a string) from the else block
      @startup_csproj_file = if (get_global_property('MonoDevelopProperties', 'StartupItem')) then
                               get_global_property('MonoDevelopProperties', 'StartupItem')
                             else
                               (find_first_exe_project) ? find_first_exe_project : @sln_file[:projects].first
                             end
    end

    def get_executable_path(type)
      raise "You must provide either 'Release' or 'Debug'" if not(type =~ /^(Debug|Release)$/)


      @csproj_file_manager = Parsers::ProjectFileParser.new("#{@repo_dir}/#{@startup_csproj_file}")
      startup_csproj = @csproj_file_manager.parse

      startup_csproj['PropertyGroup'].each do |property|
        if property.include?('Condition')
          if property['Condition'] === "'$(Configuration)|$(Platform)' == '#{type}|AnyCPU'"
            @out_path = property['OutputPath'][0].gsub(/\\/, '/').strip
          end
        end

        if property.include?('AssemblyName')
          @assembly_name = property['AssemblyName'][0].strip
        end

        if property.include?('OutputType')
          @out_type = property['OutputType'][0].strip.downcase
        end

        next
      end
      nil if (@out_path.nil? || @assembly_name.nil? || @out_type.nil?)
      "#{@repo_dir}/#{strip_csproj}/#{@out_path}#{@assembly_name}.#{@out_type}"
    end

    def get_global_property(property_tag, property)
      @sln_file[:global].each do |prop|
        prop_set = prop[:properties] if (prop[:property_tag] === property_tag)
        next if prop_set.nil?
        prop_set.each do |p|
          return p[:value].gsub(/\\/, '/') if p[:key] === property
        end
        nil
      end
    end

    def get_project_property(project_name, property)
      @sln_file[:projects].each do |project|
        if project[:assembly_info][:name] =~ /("?)#{project_name}("?)/
          return project[:assembly_info][property.to_sym].gsub(/\\/, '/') if (property != 'guid' && project[:assembly_info][property.to_sym])
          return project[:guid].gsub(/\\/, '/') if property === 'guid'
        end
      end
      nil
    end

    def strip_csproj
      @startup_csproj_file.match(/(^.*)\/.*\.csproj$/).captures[0].strip
    end

    private

    def find_first_exe_project
      @sln_file[:projects].each do |project|
        project['PropertyGroup'].each do |property_group|
          if property_group.include?('OutputType')
            project if property_group['OutputType'] === 'Exe'
          end
        end
      end
      nil
    end
  end
end
