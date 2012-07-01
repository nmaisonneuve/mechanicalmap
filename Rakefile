#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'

Mechanicalmap::Application.load_tasks

namespace :app do


  desc "synch answers"
  task :sync => :environment do
    App.all.each { |app|
       puts "app: #{app.name}"
      
      answers=app.answers.answered.where(:ft_sync => false)
      if (answers.size>0)
        puts "#{answers.size} answers to synchronize"
        FtDao.instance.sync_answers(answers)
      end
    }
  end

  desc "reindex tasks: input table id "
  task :reindex_tasks => :environment do
    #require "app/models/ft_dao.r"
    FtDao.instance.import(ENV["table"]) { |task|
            p task
    }
  end

  desc "reindex required answers"
  task :answers_gen => :environment do
    App.first.tasks.each { |task|
      1.times do
        task.answers<<Answer.create!(:state => Answer::AVAILABLE)
      end
    }
  end

end