module IronSpect
  module Parsers
    class SolutionFileParser
      attr_reader :solution_file

      def initialize(solution_file_path)
        @solution = {}
        if File.directory?(solution_file_path)
          sln_file = Dir["#{solution_file_path}/*.sln"]
          raise "Solution file not present in directory #{solution_file_path}"  if sln_file.nil?
          puts "Multiple solution files found in directory #{solution_file_path}. Accepting the first." if sln_file.count > 1
          @solution_file = File.open(sln_file[0], 'r+')
        elsif File.file?(solution_file_path)
          @solution_file = solution_file_path
        else
          raise "Didn't understand being called with #{solution_file_path}"
        end
      end

      def parse
        @solution[:projects] = []
        @solution[:global] = []
        run_parse(@solution_file.read)
        @solution
      end


      private

      def run_parse(sln_contents)
        version_info = sln_contents.scan(/^(.*)Solution\sFile,\sFormat\sVersion\s(\d+\.\d+)/)
        @solution[:version_info] = { :sln_type => version_info[0][0].strip, :sln_version => version_info[0][1].strip }
        projects = sln_contents.scan(/(^Project.*)/)
        projects.each do |project|
          @solution[:projects] << parse_project(project[0])
        end
        global_sections = sln_contents.scan(/(GlobalSection.*?EndGlobalSection)/m)
        global_sections.each do |global_section|
          @solution[:global] << parse_global_section(global_section)
        end
      end

      def parse_project(project)
        first_split = project.split('=').each { |x| x.strip }
        guid = first_split[0].scan(/.*(\"\{.*\}\").*/)[0][0]
        pre_value = first_split[1].split(',').each { |x| x.strip }
        value = {:name => pre_value[0].strip.gsub("\"", ''), :path => pre_value[1].strip.gsub("\\", '/').gsub("\"", ''), :guid => pre_value[2].strip.gsub("\"", '') }
        { :guid => guid.strip.gsub("\"", ''),  :assembly_info => value }
      end

      def parse_global_section(global_section)
        global_hash = {}
        global_hash[:properties] = []
        tmp = global_section.first.scan(/^GlobalSection\((.*?)\)\s=\s(preSolution|postSolution)(.*)(EndGlobalSection)/m)
        global_hash[:property_tag] = tmp[0][0]
        global_hash[:property_step] = tmp[0][1]
        tmp[0][2].gsub("\t", '').strip.split("\n").each do |property|
          kv_prop = property.split('=')
          global_hash[:properties] << { :key => kv_prop[0].strip, :value => kv_prop[1].strip }
        end
        global_hash
      end
    end
  end
end

