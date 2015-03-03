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
    File.open('/path/on/your/machine/newfile.txt', 'w') do |dump|  
      
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
      #done with pages close file
    end     
    
    #this code sample shows how to open up the scraped data and convert it into something that could be read by your database program.
 <parser.rb>
 
 CSV.open('/path/on/your/machine/newfile.csv', 'w',{:col_sep => "\t",:encoding => 'UTF-8'}) do |csv|
       results = Nokogiri::HTML(open("/path/on/your/machine/newfile.txt",:encoding => 'UTF-8').read)
       rows  = results.css("tr").select{|x| x.css("td").size==14 && x.css("td")[0].inner_text.match(/\A\s*\Z/).nil?}
       rows.each do |row|
         csv << row.children.css("td").map{|r| r.text.strip}
       end
 end
 
   # this code shows how to read incidents from your database, grab the corresponding PDF, and dump that text into another database table, plus pull out key fields with regex.
   #example url       the_url="http://www.ndhealth.gov/EHS/FOIA/Spills/Summary_Reports/20140716184201_summary_report.pdf"
 <pdfgetter.rb>

    require 'pdf/reader'
    require 'net/http'
    require 'open-uri'
    # get a list of incidents from the database
     toget=Incidents.all(:limit=>10)  #limit to 10 to test our your script first
     toget.each do |t|
     the_url="http://www.ndhealth.gov/EHS/FOIA/Spills/Summary_Reports/"<<t.incident_id.to_s<<"_summary_report.pdf"
     web_contents  = open(the_url) 
     #load contents into a variable called reader
     reader = PDF::Reader.new(web_contents) 
     the_text=""
      reader.pages.each do |page|
        the_text << page.text
      end
      #dump text into a table in the datase
      n=FullText.new
      n.incident_id=t.incident_id
      n.the_doc=the_text
      #regex to pull out responsible party
      n.responsible_party=the_text.match(/\bResponsible Party:\s?(.+)/)[1].lstrip.rstrip 
      n.save!
      puts t.incident_id
    end
   
 
 
