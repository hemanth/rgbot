 require 'rubygems'  
 require 'xmpp4r-simple'  
 require 'open-uri'

class L33ty


    def initialize(bot_name,bot_password)
        @bot  =  bot_name
        @pass = bot_password
        @jabber = Jabber::Simple.new(@bot+'@gmail.com',@pass)
    end
    
    def invoke(msg)
        restricted_methods=['main','invoke','deliver']
        meth=msg.body.split()[0]
        self.send(meth,msg) if self.respond_to?(meth) and !restricted_methods.include?(meth) 
    end
    
    def deliver(msg,res)
        @jabber.deliver(msg.from.node+"@gmail.com",res)
    end

    def l33t(msg)
        self.deliver(msg,open('http://nyhacker.org/~hemanth.hm/hacks/t.php?'+ URI.escape(msg.body, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))).read())
    end
    
    def goog(msg)
        
        
        
    end
    
    def main   
        while (true) do  
             @jabber.received_messages do |msg|  
             File.open('log', 'w') {|log| log.write(msg.from.node+" : "+msg.body)}
             self.invoke(msg)
           end
        end
        sleep(1) 
    end 
end

l33t = L33ty.new('gmail_user_name','password')
l33t.main()

