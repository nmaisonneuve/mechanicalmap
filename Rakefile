#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

desc "test fusion table"
task :ft=>:environment do

	dao=FtDao.instance

	attributes=[{:name=>"toto", :type=>"string"}]

	table=dao.create_table("toto",attributes)
	p table
end