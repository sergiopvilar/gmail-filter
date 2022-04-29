class Filter

  def initialize (emails)
  	@emails = emails.strip.split(',')
  	@emails.each {|email| email.strip!}
  end

  def build_it
		filter = ""
		@emails.each_slice(3).to_a.each do |emails|
			filter += "
				<entry>
					<category term='filter'></category>
					<title>Mail Filter</title>
					<id></id>
					<updated></updated>
					<content></content>
					<apps:property name='from' value='#{emails.join(' OR ')}'/>
					<apps:property name='shouldTrash' value='true'/>
					<apps:property name='sizeOperator' value='s_sl'/>
					<apps:property name='sizeUnit' value='s_smb'/>
				</entry>"
		end

		filter
	end
end

class GmailFilter

  attr_reader :output_text

  def initialize
  	@output_text = "<?xml version='1.0' encoding='UTF-8'?>
  	<feed xmlns='http://www.w3.org/2005/Atom' xmlns:apps='http://schemas.google.com/apps/2006'>
	<title>Mail Filters</title>
		"
	@filename = ''
	@text_string = ''
  end

  def build_from_filename
  	print 'Input filename: '
  	@filename = gets.strip
  	@text_string = IO.read(@filename)
  end

  def build_filters(text_string = nil)
		filter = Filter.new(text_string)
		@output_text += filter.build_it
	@output_text += "

</feed>"
  end

  def export_filters_to_file
	File.open('mailfilters.xml','w') do |file|
	  file.puts @output_text
	end
  end

end

#___________________________

#EXAMPLE USES:

#Reading from existing file, user is prompted for filename:
#output = GmailFilter.new
#output.build_from_filename
#output.build_filters
#puts output.output_text

#Reading from directly input text:
#output = GmailFilter.new
#output.build_filters('thislabel: emily.sommer@gmail.com, another@email.com; "this search phrase"')
#puts output.output_text
