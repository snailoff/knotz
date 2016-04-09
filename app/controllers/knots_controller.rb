class KnotsController < ApplicationController
	def index
		@knots = Knot.order('updated_at DESC').all
	end

	def show
		@knot = Knot.find(params[:id])

		@content = parse_body @knot.content

		@headerImage = nil
		["png", "jpg", "gif"].each do |ext|
			file = "#{@knot.name}.#{ext}"
			
			if Rails.application.assets.find_asset file
				@headerImage = "/assets/#{file}"
				break
			end

			@headerImage = "/assets/floor.jpg"
		end

	end

	def parse_body content
			parsed = ''
			isParagraphBlock = false
			isCodeBlock = false
			codeBlockContent = ''
			codeBlockName = ''

			content.split(/\n/).each do |line|

				if isCodeBlock 
					if line =~ /^```(.*)?$/
						require 'rouge'

						lexer = Rouge::Lexer.find codeBlockName

						if lexer 
							source = codeBlockContent
							formatter = Rouge::Formatters::HTML.new(css_class: 'highlight')
							result = formatter.format(lexer.lex(source))
							parsed += result
						else
							parsed += '<div class="codeblock"><pre>'
							# parsed += safeHtml(codeBlockContent)
							parsed += codeBlockContent
							parsed += '</pre></div>'
						end

						isCodeBlock = false
						codeBlockContent = ''
						codeBlockName = ''
						next
						
					else
						codeBlockContent += line + "\n"
						next
					end
				else
					if line =~ /^```(.*)?$/
						codeBlockName = $1
						isCodeBlock = true
						next
					end

				end

				line.strip!

				if line =~ /^"""/
					isParagraphBlock = isParagraphBlock ? false : true
					next
				end

				if line =~ /^---/
					parsed += "<hr />"
					next
				end
					
				line.gsub! /^(\={1,5})(.*)$/ do "<h#{$1.to_s.length}>#{$2}</h#{$1.to_s.length}>" end

				if /``(?<code>.*?)``/ =~ line
					line = "#{special($`)}<span class=\"codeline\">#{safeHtml(code)}</span>#{special($')}"

					line += "<br />" if isParagraphBlock
					parsed += line + "\n"
					next
				end

				special line

				# if line =~ /\(\((?:(.*?)(?: (.*?))?)\)\)/
				# 	rs = Extension.new(@config).build($1, $2)
				# 	line.gsub! $&, rs
				# end

				line += "<br />" unless isParagraphBlock

				parsed += line + "\n"
			end

			parsed
	  	end

	  	def special str
	  		str.gsub! /\*\*(.*?)\*\*/, "<strong>\\1</strong>"
			str.gsub! /__(.*?)__/, "<u>\\1</u>"
			str.gsub! /\/\/(.*?)\/\//, "<i>\\1</i>"	
			str.gsub! /~~(.*?)~~/, "<del>\\1</del>"
			str
	  	end


end
