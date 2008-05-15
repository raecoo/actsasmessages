# ActsAsMessages Generator Model
class Message < ActiveRecord::Base
  
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id'
  belongs_to :receiver, :class_name => 'User', :foreign_key => 'receiver_id'
  
  validates_presence_of :title,:body
  
  # make the message is read
  def mark_read
    update_attribute('read',1)
  end
  
end
