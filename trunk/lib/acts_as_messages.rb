# ActsAsMessages
module Raecoo
  module Acts #:nodoc:
    module Messages #:nodoc:
      
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_messages
          
          has_many :sent_messages, :class_name => 'Message', :foreign_key => "sender_id", 
            :conditions => "sender_deleted=0" , :dependent => :destroy,:order => "created_at DESC"
          
          has_many :received_messages, :class_name => 'Message', :foreign_key => "receiver_id", 
            :conditions => "receiver_deleted=0" , :dependent => :destroy,:order => "created_at DESC"
          
          has_many :unread_messages, :class_name => 'Message', :foreign_key => "receiver_id",
            :order => "created_at DESC", :conditions => "#{Message.table_name}.read = 0 and #{Message.table_name}.receiver_deleted=0"

          include Raecoo::Acts::Messages::InstanceMethods
          #        extend Raecoo::Acts::Messages::SingletonMethods
        end
        
      end

      #      module SingletonMethods
      #        # Add class methods here
      #      end

      module InstanceMethods

        # Creates new Message from the given parameters 
        # params:
        # recipient  => receive message's user 
        # title  => the title of message
        # body  => the body of message
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   bill = User.find_by_name('bill')
        #   raecoo.send_message(bill, 'I will buy Microsoft,How money?', 'this is joke... haha')  
        def send_message(recipient,title,body)
          msg = Message.new(:sender => self, :receiver =>recipient, :title => title,  :body => body) 
          msg.save!
        end
        
        # Remove Message to Trash
        # params:
        # message  => operation object 
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   msg = Message.find(1)
        #   raecoo.trash_message(msg)          
        def trash_message(message)
          self == message.sender ? message.update_attribute('sender_deleted',1) : message.update_attribute('receiver_deleted',1)
        end       

        # Resumption Message to Inbox or Outbox According to its source 
        # params:
        # message  => operation object 
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   msg = Message.find(1)
        #   raecoo.trash_message(msg)          
        def untrash_message(message)
          self == message.sender ? message.update_attribute('sender_deleted',0) : message.update_attribute('receiver_deleted',0)
        end          
        
        # Return user's inbox message
        # params:
        # page  => Equivalent to Will_paginate params :page
        # per_page  => Equivalent to Will_paginate params :per_page
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   raecoo.inbox_messages(params[:page])          
        def inbox_messages(page,per_page=10)
          received_messages.paginate :page => page, :per_page => per_page,:order => "created_at DESC"
        end
        
        # Return user's sent message
        # params:
        # page  => Equivalent to Will_paginate params :page
        # per_page  => Equivalent to Will_paginate params :per_page
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   raecoo.sent_messages(params[:page])          
        def sent_messages(page,per_page=10)
          sent_messages.paginate :page => page, :per_page => per_page,:order => "created_at DESC"
        end
        
        # Return user's trash message
        # params:
        # page  => Equivalent to Will_paginate params :page
        # per_page  => Equivalent to Will_paginate params :per_page
        # Use Guide :
        #   raecoo = User.find_by_name('raecoo')
        #   raecoo.trash_messages(params[:page])           
        def trash_messages(page,per_page=10)
          Message.paginate :page => page, :per_page => per_page,:order => "created_at DESC",
            :conditions => ["(sender_id =? and sender_deleted =1) or (receiver_id =? and receiver_deleted =1)",self.id,self.id]
        end    
        
        # Have not yet read the message back to
        # params:
        # onlynum  => Only to return to the number of unread message,default 
        #                        Rather will return to all unread messages
        # Use Guide :
        #  raecoo = User.find_by_name('raecoo')
        #  count = raecoo.unread_message
        #  messages = raecoo.unread_message(false) # messages is a Message collection
        def unread_message(onlynum = true)
          if onlynum
            unread_messages.count(:select => 'id')
          else
            unread_messages.find(:all)
          end
        end
        #TODO clear all message in trash
        def clean_trash
          
        end
        
      end
      
    end
  end
end

# open ActiveRecord and  include all the above method into it
ActiveRecord::Base.class_eval do
  include Raecoo::Acts::Messages
end