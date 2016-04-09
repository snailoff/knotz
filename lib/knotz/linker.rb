module Knotz
	class Linker

		def self.reset_links
			db = SQLite3::Database.new Knotz.mainConfig[:db_path]
			db.execute "DELETE FROM LINKS"

			Knotz::Manager.all_knots.each do |knot|
				knotFrom, knotTo = Knotz::Linker.draw_knot knot
				puts "---> #{knot} : #{knotFrom}, #{knotTo}"

				begin
					knotFrom.each do |from|
						db.execute "INSERT INTO LINKS VALUES (?, ?)", [from, knot]
						puts ": #{from} => #{knot}"
					end
					
					knotTo.each do |to|
						db.execute "INSERT INTO LINKS VALUES (?, ?)", [knot, to]
						puts ": #{knot} => #{to}"
					end
				rescue
					Knotz.logger.error "links duplication error."
				end
			end
		end

		def self.draw_knot knotName
			file = Knotz::Config.knot_full_path knotName
			from = []
			to = []
			File.foreach file do |line|
				if /^@>\s*(?<knots>.*?)\s*$/ =~ line
					knots.split(/\s*,\s*/).each do |knot|
						to << knot if Knotz::Config.knot_exist? knot
					end
				end
				if /^@<\s*(?<knots>.*?)\s*$/ =~ line
					knots.split(/\s*,\s*/).each do |knot|
						from << knot if Knotz::Config.knot_exist? knot
					end
				end
			end

			return [from.uniq, to.uniq]
		end


		def initialize config
			@config = config
			@db = SQLite3::Database.new Knotz.mainConfig[:db_path]
		end

		def link
			knot = @config[:knot]

			# TO
			fileTos = @config[:knot_to]
			dbTos = tos knot

			addTos = fileTos - dbTos
			delTos = dbTos - fileTos

			db_add_tos knot, addTos
			db_del_tos knot, delTos

			# FROM
			fileFroms = @config[:knot_from]
			dbFroms = froms knot

			addFroms = fileFroms - dbFroms
			delFroms = dbFroms - fileFroms

			db_add_froms knot, addFroms
			db_del_froms knot, delFroms

			(addTos + delTos).uniq.each do |knot|
				refresh_plain knot
			end
		end

		def refresh_plain knot
			Knotz.logger.debug "refresh : #{knot}"
			tosJoined = "@> #{tos(knot).join ", "}" 
			fromsJoined = "@< #{froms(knot).join ", "}"

			content = ''
			File.foreach Knotz::Config.knot_full_path(knot) do |line|
				if line =~ /^@>/
					content += "#{tosJoined}\n"
				elsif line =~ /^@</
					content += "#{fromsJoined}\n"
				else
					content += line
				end
			end

			Knotz::Manager.write_knot knot, content
		end

		def tos knot
			rs = []
			@db.execute( "SELECT KNOT_TO FROM LINKS WHERE KNOT_FROM = ?", [knot] ) do |row| 
				rs << row[0]
			end
			rs
		end

		def froms knot
			rs = []
			@db.execute( "SELECT KNOT_FROM FROM LINKS WHERE KNOT_TO = ?", [knot] ) do |row| 
				rs << row[0]
			end
			rs
		end

		def db_add_tos knot, tos
			tos.each do |to|
				@db.execute("INSERT INTO LINKS VALUES (?, ?)", [knot, to])
			end
		end 

		def db_del_tos knot, tos
			tos.each do |to|
				@db.execute( "DELETE FROM LINKS WHERE KNOT_FROM = ? AND KNOT_TO = ?", [knot, to] )
			end
		end 

		def db_add_froms knot, froms
			froms.each do |from|
				@db.execute("INSERT INTO LINKS VALUES (?, ?)", [from, knot])
			end
		end

		def db_del_froms knot, froms
			froms.each do |from|
				@db.execute( "DELETE FROM LINKS WHERE KNOT_FROM = ? AND KNOT_TO = ?", [from, knot] )
			end
		end


		
	end
end