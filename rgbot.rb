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
         gurl = "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q="+URI.escape(msg.body, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
         self.deliver(msg,JSON.parse(Net::HTTP.get_response(URI.parse(gurl)).body)['responseData']['results'][0]['url'])  
    end

    def xkcd(msg)
       uri = URI.parse 'http://dynamic.xkcd.com/random/comic/'
       req = Net::HTTP::Get.new(uri.request_uri)
       http = Net::HTTP.new(uri.host)
       res = http.start { |server|
       server.request(req)
       }
       self.deliver(msg,res["location"]+ " Enjoy it!")
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

