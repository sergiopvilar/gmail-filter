#testapp.rb
require 'rubygems'
require 'sinatra'
require 'net/imap'
require 'dotenv/load'
require './gmail.rb'

helpers do
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
	imap = Net::IMAP.new("imap.gmail.com", 993, true, nil, false)
	imap.login(ENV['GMAIL_ACCOUNT'], ENV['GMAIL_PASSWORD'])
	imap.examine(ENV['GMAIL_FOLDER'])
	emails = []

	imap.search(["ALL"]).each do |message_id|
		env = imap.fetch(message_id, "ENVELOPE")[0].attr["ENVELOPE"]
		emails.push("#{env.from[0].mailbox}@#{env.from[0].host}")
	end

	@emails = emails.uniq.join(', ')
	erb :gmailapp
end

post '/gmail_app_backend' do
	safety = Rack::Utils.escape_html(params['formtext'])
	replaced = safety.gsub!('&#x2F;','/') || safety
	output = GmailFilter.new
	output.build_filters(replaced)
	@output = output.output_text
	erb :results
end

post '/download' do
	attachment 'mailfilters.xml'
	params['write_data']
end
