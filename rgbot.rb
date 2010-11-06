 require 'rubygems'  
 require 'xmpp4r-simple'  
 require 'open-uri'
 require 'net/http'
 require 'json'
 require 'httpclient'
 require 'dbm'

=begin
* Name:rgbot 
* Description : rgbot is an XMPP bot build with ruby, that runs on gmail and can do things like :
  * l33t translation 
  * Google I'm feeling lucky search 
  * Karma system
  * XCKD random images
  * Flipping a coin, throwing the dice
* Author:Hemanth.HM <hemanth.hm@gmail.com>
* Date:5/11/2009
* License:GNU GPLv3
=end

class L33ty

    def initialize(bot_name,bot_password)
        # Initialize bot name and password
        @bot  =  bot_name
        @pass = bot_password
        # Make a connection 
        @jabber = Jabber::Simple.new(@bot+'@gmail.com',@pass)
    end
    
    def invoke(msg)
        # This method takes care of invokation of the required 
        # method from the factoid that the user throws at.
        
        # The below are the restricted methods, that must not be invoked
        restricted_methods=['main','invoke','deliver']
        # Get the method name from the chat msg
        meth=@msg.body.split()[0]
        # Remove the method name from the chat msg and save the rest
        @msg.body=@msg.body.sub(/\w+\s*/, '')
        if (self.respond_to?(meth) and !restricted_methods.include?(meth))
            # If the method to be invoked is present and is not a restricted one then invoke it.
            # Use obj.send(method,args) => method(args) similar to py's getattr
            self.send(meth,@msg)
        else
            # If not then alter the user of what he can do
            self.deliver(@msg,"I don't get what your are saying "+@msg.from.node+", but you can teach me @ https://github.com/hemanth/rgbot"    )
        end
    end
    
    def deliver(msg,res)
        @jabber.deliver(@msg.from.node+"@gmail.com",res)
    end

    def help(msg)
        self.deliver(@msg,"Try l33t <str>, goog <str>, xkcd, flip, flop, roll, greet, fortune, karma nick++/--")
    end
    
    def l33t(msg)
        self.deliver(@msg,open('http://nyhacker.org/~hemanth.hm/hacks/t.php?'+ URI.escape(@msg.body, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))).read())
    end

    def goog(msg)
         gurl = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q="+URI.escape(@msg.body, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
         self.deliver(@msg,JSON.parse(Net::HTTP.get_response(URI.parse(gurl)).body)['responseData']['results'][0]['url'])  
    end

    def xkcd(msg)
       uri = URI.parse 'http://dynamic.xkcd.com/random/comic/'
       req = Net::HTTP::Get.new(uri.request_uri)
       http = Net::HTTP.new(uri.host)
       res = http.start { |server|
       server.request(req)
       }
       self.deliver(@msg,res["location"]+ " Enjoy it!")
    end
    
     def karma(msg)
        kdb = DBM.open("karma.db")
        if(@msg.body.empty?)
           self.deliver(@msg,"Wrong usage! Do karma nick ++ or --")
        else 
           whom,what = @msg.body.split(/(?=\+\+)|(?=\-\-)/)
           if (what.nil? && !kdb[whom].nil?)
               self.deliver(@msg,"Karma of "+whom+" : "+kdb[whom])
               elsif(kdb[whom].nil?)
                  kdb[whom]=0
                  self.deliver(@msg,"New avatra, your karma is 0")
               elsif((whom <=> @msg.from.node) == 1)
                  kdb[whom]=kdb[whom].to_i-1
                  self.deliver(@msg,"Very smart! your karma is : "+kdb[whom])
               elsif((what <=> "++") == 0)
                  kdb[whom]=kdb[whom].to_i+1
                  self.deliver(@msg,"Karma is : "+kdb[whom])
               elsif((what <=> "--")== 0)
                  kdb[whom]=kdb[whom].to_i-1
                  self.deliver(@msg,"Karma is : "+kdb[whom])
           else
              self.deliver(@msg,"Wrong usage! Do karma "+whom+" ++ or --")
        end
     end
    end
   
    def roll(msg)
        self.deliver(@msg,(1..6).to_a.choice)
    end

    def fortune(msg)
       IO.popen("fortune") { |cmd| self.deliver(@msg,cmd.gets) }
    end
    
    def greet(msg)
        if(!@msg.body.nil?)
           self.deliver(@msg,"Hey "+@msg.body+" :)")
        end
    end

    def flip(msg)
        self.deliver(@msg,['head','tail'].choice)
    end

    def flop(msg)
        self.deliver(@msg,"Flip it!")
    end

    def hi(msg)
        self.deliver(@msg,"Hey "+@msg.from.node+" :)")
    end
  
    def main   
        while (true) do  
             @jabber.received_messages do |@msg|  
             File.open('log', 'w') {|log| log.write(@msg.from.node+" : "+@msg.body)}
             self.invoke(@msg)
           end
        end
        sleep(1) 
    end 
end

l33t = L33ty.new('gmail_user_name','password')
l33t.main()

