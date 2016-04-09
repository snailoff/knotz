module Knotz
	class Parser

		def self.parse config
			content = ''
			config[:knot_plain].split(/\n/).each_with_index do |line, index|
				case index
				when 0
					if /^@@(?<subject>.*)$/ =~ line
						config[:parsed_subject] = subject.strip
					end
				when 1
					if /^@<\s*(?<froms>.*)\s*$/ =~ line
						config[:parsed_froms] = []
						froms.split(/\s*,\s*/).each do |from|
							config[:parsed_froms] << from.strip
						end
					end
				when 2
					if /^@>\s*(?<tos>.*)\s*$/ =~ line
						config[:parsed_tos] = []
						tos.split(/\s*,\s*/).each do |to|
							config[:parsed_tos] << to.strip
						end
					end
				else
					content += "#{line}\n"
				end
			end

			config[:knot_content] = content
		end

		def self.precheck config
			checker = true
			config[:knot_plain].split(/\n/).each_with_index do |line, index|
				case index
				when 0
					checker = false unless line =~ /^@@/
				when 1
					checker = false unless line =~ /^@</
				when 2
					checker = false unless line =~ /^@>/
				else
					break
				end
			end

			Knotz.logger.debug "check ok? => #{checker}"

			unless checker
				content = "@@ #{config[:knot]}\n@< \n@> \n"
				config[:knot_plain].split(/\n/).each do |line|
					if line =~ /^(@@|@<|@>)/
						next
					end
					content += "#{line}\n"
				end

				Knotz::Fetcher.write_knot config[:knot], content

				File.write config[:knot_path], content

				Knotz.logger.info "knot(plain) is modified. restart."

				raise "knot's format is adjusted."
			end
		end
	end
end
