
module Knotz

	def self.initConfig
  		@mainConfig =  {
			template_path: 'data/template/knotz.tpl',
			db_path: 'db/development.sqlite3',
			knot_path: 'data/plain',
			extension_path: 'data/extension'
		}

		@mainConfig.each { |_,x| x.replace File.join(Knotz.base_dir, x) }

		puts "======> #{@mainConfig}"
	end

	class Config
		def self.knot_full_path knotName
			File.join Knotz.mainConfig[:knot_path], "#{knotName}.knot"
		end

		def self.knot_exist? knotName
			File.exist? knot_full_path(knotName)
		end

	end
end