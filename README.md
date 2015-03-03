# nd_oil_incidents
This is some sample code that we used in reporting on environmental incidents involving the North Dakota oil industry.

See http://www.nytimes.com/interactive/2014/11/23/us/north-dakota-oil-boom-downside.html.

A key component of the project was to download incident reports from the state's <a href="http://www.ndhealth.gov/ehs/spills/">web site</a> and turn it into an analyzable database. The code samples (written in Ruby)  will give you a rough idea of how we used the Watir browser emulator to do the downloading, Nokogiri to do the parsing, with some Regex to pull information out of the PDF files.

I would never argue that this code is the best code ever, but it worked for us and might help other reporters who want a rough idea of how one might approach stories that involve scraping and parsing.

Please contact me at rgebeloff@nytimes.com if you have any questions or suggestions.
