namespace :radiant do
  namespace :extensions do
    namespace :copy_move do
      
      desc "Runs the migration of the CopyMove extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          CopyMoveExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          CopyMoveExtension.migrator.migrate
        end
      end
      
      desc "Copies files in public/admin"
      task :move_files => :environment do
        extension_public = File.join(File.dirname(__FILE__), '../', '../', 'public')
        cp_r extension_public, RAILS_ROOT
      end
      
      desc "Migrates and copies files in public/admin"
      task :install => [:environment, :migrate, :move_files] do        
      end
    
    end
  end
end unless __FILE__.include? '_darcs'