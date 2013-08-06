require_relative 'iron-spect/version'
require_relative '../lib/iron-spect/parsers/solution_file_parser'
require_relative '../lib/iron-spect/parsers/project_file_parser'

module IronSpect
  class Inspecter

    def initialize(repo_dir=Dir.getwd)
      @sln_file_manager = Parsers::SolutionFileParser.new(repo_dir)
      @sln_file = @sln_file_manager.parse
      @repo_dir = repo_dir
      @startup_csproj_file = if (get_global_property('MonoDevelopProperties', 'StartupItem')) then
                               load_project get_global_property('MonoDevelopProperties', 'StartupItem')
                             else
                               (first_exe_project) ? first_exe_project : @sln_file[:projects].first
                             end

    end


    def startup_project
      @startup_csproj_file
    end


    def startup_executable_path(configuration, platform='AnyCPU')

      #break out early if the configuration or type provided is invalid
      nil if not(configuration =~ /^(Debug|Release)$/)
      nil if not(platform =~ /^(AnyCPU|x86|x64|Itanium)$/)

      @csproj_file_manager = Parsers::ProjectFileParser.new(startup_local_path)
      startup_csproj = @csproj_file_manager.parse

      startup_csproj['PropertyGroup'].each do |property|
        if property.include?('Condition')
          if property['Condition'] === "'$(Configuration)|$(Platform)' == '#{configuration}|#{platform}'"
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
        #puts prop[:properties] if (prop[:property_tag] === property_tag)
        prop_set = prop[:properties] if (prop[:property_tag] === property_tag)
        next if prop_set.nil?
        prop_set.each do |p|
          return p[:value].gsub(/\\/, '/') if p[:key] === property
        end
      end
      nil
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


    private

    def first_exe_project
      @sln_file[:projects].each do |project|
        parsed = Parsers::ProjectFileParser.new(project[:assembly_info][:path]).parse
        parsed['PropertyGroup'].each do |property_group|
          if property_group.include?('OutputType')
            if property_group['OutputType'].first === 'Exe'
              return project
            end
          end
        end
      end
      nil
    end


    def load_project(path)
      @sln_file[:projects].each do |project|
        if (project[:assembly_info][:path] === path)
          return project
        end
        next
      end
      nil
    end


    def strip_csproj
      startup_local_path.match(/(^.*)\/.*\.csproj$/).captures[0].strip
    end

    def startup_local_path
      @startup_csproj_file[:assembly_info][:path]
    end

  end
end
