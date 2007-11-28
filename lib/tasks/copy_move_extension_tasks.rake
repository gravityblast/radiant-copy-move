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
      
      desc "Copies public assets of the CopyMove extension to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        Dir[CopyMoveExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(CopyMoveExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      
      desc "Migrates and copies files in public/admin"
      task :install => [:environment, :migrate, :update] do
      end
    
    end
  end
end