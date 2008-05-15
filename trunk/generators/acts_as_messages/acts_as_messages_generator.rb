class ActsAsMessagesGenerator < Rails::Generator::Base 
  def manifest 
    record do |m| 
      # Models
      m.file "models/message.rb", "app/models/message.rb"
      #Migrations
      m.migration_template 'migration.rb', 'db/migrate' , 
        :migration_file_name => "acts_as_messages_migration"
      m.readme "INSTALL"
      
    end 
  end
  
end
