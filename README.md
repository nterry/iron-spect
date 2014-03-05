# IronSpect

[![Build Status](https://travis-ci.org/nterry/iron-spect.png?branch=master)](https://travis-ci.org/nterry/iron-spect)&nbsp;&nbsp;&nbsp;&nbsp;[![Gem Version](https://badge.fury.io/rb/iron-spect.png)](http://badge.fury.io/rb/iron-spect)

## Description

IronSpect is a parser, serializer, and deserializer for Visual Studio 2010, 2012, and 2013 projects. It handles both .sln files and .csproj files.

## Installation

Add this line to your application's Gemfile:

    gem 'iron-spect'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iron-spect

## Usage

First, initialize a new Inspecter object

	inspecter = IronSpect::Inspecter.new(repo_directory)	#repo_directory defaults to dir.getwd

Then, simply call one of the methods in the Inspecter class on the object. Here are a few examples:

	startup_project = inspecter.startup_project
	startup_exe_path = inspecter.startup_executable_path
	
	some_global_property = inspecter.get_global_property("property_tag", "property_name")
	some_project_property = inspecter.get_project_property("project_name", "property_name")

And thats it! It is, quite literally, that simple to use. 

Happy coding!!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
