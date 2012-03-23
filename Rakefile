#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

desc "synch answers"
task :sync=>:environment do

  Unit.all.completed.where(:sync_ft=>false).each { |answer|
      FtDao.instance.enqueue
      answer.synch_ft=true
      answer.save
  }
end
