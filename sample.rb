#these are sample scripts intended as demos on how to scrape and parse data from the Web using the Watir browser emulator, Ruby's PDF library and regular expressions.
#it's possible that at this point, this could be done without the browser emulator, but at the time I did this in 2014, the .Net and JS code involved made the browser emulator an easier solution.
#i make no claim of this being the best way to do things, but this code does work and could help somebody getting started in this area. for comments and questions, please contact me at rgebeloff@nytimes.com

#example of scraping .Net site with Watir browser. this script will loop through many pages on a site and dump the content to a text file, which we'll parse with a separate script

<downloader.rb>
    #make sure these gems are installed on your system, ex: gem install watir, or within an app, add to your gemfile, ex: gem 'watir'
    require 'rubygems'
    require 'watir'
    require 'watir-webdriver'
    require 'nokogiri'
    #open a file to receive the data 
    File.open('/path/on/your/machine', 'w') do |dump|  
      
      #fire up a browser -- I found firefox worked better for me, but ymmv
      
      browser =  Watir::Browser.new :firefox
      Watir.default_timeout = 90
      browser.goto 'http://www.ndhealth.gov/ehs/foia/spills/defaultOGContained.aspx'
      
      #use Nokogiri to handle the content
      
      opening_page = Nokogiri::HTML.parse(browser.html)
      
      #figure out how many pages we need to grab by using Nokogiri CSS selector
      
      total_pages=opening_page.css("span[id='LabelPageCount']")[0].inner_text.to_i
      current_page=1
      
      #loop through pages and grab the table HTML using a css selector and append it to our text file.
      
      while current_page < total_pages  do
        page_html = Nokogiri::HTML.parse(browser.html)
        the_table=page_html.css("table[id='GridView1']")[0]
        dump.puts the_table
        #prepare to move onto next page and report current status to terminal window
        current_page=current_page+1
        puts current_page
        #be courteuous to the server and pause between pages
        sleep(rand(10..20))
        #click the "next" button, identified by CSS tag
        browser.button(:id => "rptPager__ctl2_lnkPage").click
      end
      #done with pages
    end     
