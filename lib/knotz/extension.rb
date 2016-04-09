module Knotz
	class Extension
		def initialize config
			@config = config
		end

		def build ext, arg
			klass = ext.capitalize
			path = File.join Knotz.base_dir, "data/extension/#{ext}.rb"
			Knotz.logger.debug "extension(#{ext}) : #{path}"

			if !File.exist? path
				Knotz.logger.error "#{path} is not exist!!"
				return "<strong>no '#{ext}' extension</strong>"
			end

			eval "require \"#{path}\""
			rs = eval "#{klass}.build(\"#{arg}\")"
		end

		def rebuild
			contained.each do |target| 
				Knotz.logger.debug "========== rebuild => #{target} START =========="
				Knotz.start([target], {isRebuild: true})
				Knotz.logger.debug "========== rebuild => #{target} END =========="
			end

		end

		private 

		def contained
			rs = []
			knots = Dir.glob "../data/plain/*.knot"
			knots.each do |knot|
				File.foreach knot do |line|
					if line =~ /\(\(.*?\)\)/
						rs << knot
						break
					end
				end
			end
			rs
		end
	end
end