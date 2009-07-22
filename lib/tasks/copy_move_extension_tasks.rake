namespace :radiant do
  namespace :extensions do
    namespace :copy_move do
      
      desc "Runs the migration of the Copy Move extension"
      task :migrate => :environment do
        require 'radiant/extension_migrator'
        if ENV["VERSION"]
          CopyMoveExtension.migrator.migrate(ENV["VERSION"].to_i)
        else
          CopyMoveExtension.migrator.migrate
        end
      end
      
      desc "Copies public assets of the Copy Move to the instance public/ directory."
      task :update => :environment do
        is_svn_or_dir = proc {|path| path =~ /\.svn/ || File.directory?(path) }
        puts "Copying assets from CopyMoveExtension"
        Dir[CopyMoveExtension.root + "/public/**/*"].reject(&is_svn_or_dir).each do |file|
          path = file.sub(CopyMoveExtension.root, '')
          directory = File.dirname(path)
          mkdir_p RAILS_ROOT + directory, :verbose => false
          cp file, RAILS_ROOT + path, :verbose => false
        end
      end  
    end
  end
end
