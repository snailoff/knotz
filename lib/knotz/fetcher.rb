
module Knotz
	class Fetcher
		def self.dbconnect
			ActiveRecord::Base.establish_connection(
				adapter:  'sqlite3', # or 'postgresql' or 'sqlite3'
				host:     'localhost',
				database: Knotz.mainConfig[:db_path],
				username: '',
				password: ''
			)
		end

		def self.exist_by_name name
			Knotz::Fetcher.dbconnect

			Knot.exists? name: name
		end

		def self.knot_by_name name
			Knotz::Fetcher.dbconnect

			Knot.find_by name: name			
		end

		def self.merge_knot config
			knot = self.knot_by_name config[:knot] 

			if knot
				self.update knot.id, config[:knot], config[:knot_content]
			else
				self.insert config[:knot], config[:knot_content]
			end
		end

		def self.merge_link config
			knot = self.knot_by_name config[:knot]

			config[:parsed_froms].map!{ |from| Knot.find_by name: from }.compact!
			config[:parsed_tos].map!{ |to| Knot.find_by name: to }.compact!
			knot.linked_from = config[:parsed_froms]
			knot.linked_to = config[:parsed_tos]
			
			knot.save
		end

		def self.update id, name, content
			Knotz::Fetcher.dbconnect

			knot = Knot.find id
			if knot
				knot.name = name
				knot.content = content
				knot.updated_at = Time.now
				knot.save
			else
				raise "no id"
			end
		end

		def self.insert name, content
			Knotz::Fetcher.dbconnect

			knot = Knot.new
			knot.name = name
			knot.content = content
			knot.created_at = Time.now
			knot.updated_at = Time.now
			knot.save
		end

		def self.delete_by_name name
			Knotz.logger.debug "knot('#{name}') is deleting."
			Knotz::Fetcher.dbconnect

			knot = Knot.find_by name: name
			if knot
				knot.destroy
			else 
				raise "no id"
			end
		end


		def self.all_knots
			target = File.join(Knotz.mainConfig[:knot_path], "*.knot")
			files = Dir.glob(target)
			files.map! do |file|
				File.basename(file, ".knot")	
			end
		end

		def self.fetch knot
			file = Knotz::Config.knot_full_path knot
			File.read file
		end

		def self.write_knot knot, content
			file = Knotz::Config.knot_full_path knot
			File.write file, content
		end

		

	end
end