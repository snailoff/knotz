# require "knotz/version"
# require "knotz/parser"
# require "knotz/config"
# require "knotz/fetcher"
# require "knotz/logger"
# require "knotz/template"
# require "knotz/extension"
# require "knotz/linker"

# require "sqlite3"


Knotz.logger.level = Logger::DEBUG

module Knotz
 	class << self
		attr_accessor :mainConfig

		def start(paths, *args)
			Knotz.logger.info "==="
			Knotz.logger.info "=== Knotz start"
			Knotz.logger.info "==="
			Knotz.logger.info ""

			begin
				paths.each do |path|
					case path
					when /\.knot$/
						self.start_knot path, args
					when /\.(jpg|png|gif)$/
						self.start_image path, args
					else
						puts "else..."
					end
				end

			rescue Exception => e
				Knotz.logger.error "** #{e.message}"
				Knotz.logger.error "***"
				e.backtrace.each do |li|
					puts li
				end
			end

			Knotz.logger.info "==="
			Knotz.logger.info "=== Knotz end"
			Knotz.logger.info "==="
			Knotz.logger.info ""
	  	end

	  	def start_knot path, args
	  		@config = {}.merge args.pop
			@config[:knot_path] = path
			@config[:read_file] = File.basename path
	        @config[:knot] = @config[:read_file].sub /\..*$/, ''

	        Knotz.logger.info "** Knot : #{@config[:knot]}"		
	  		Knotz.logger.debug "** config : #{@config}"
	        Knotz.logger.debug "** target : #{@config[:read_file]}"

	        case 
	        when @config[:type] == :ADDED || @config[:type] == :MODIFIED
	        	puts "added or modifed"

				@config[:knot_plain] = File.read @config[:knot_path]

				Knotz::Parser.precheck @config
				Knotz::Parser.parse @config

				Knotz.logger.debug "** config after parse : #{@config}"

				Knotz::Fetcher.merge_knot @config
				Knotz::Fetcher.merge_link @config

	        when @config[:type] == :REMOVED
	        	Knotz::Fetcher.delete_by_name @config[:knot]
	        else
	        	Knotz.logger.error "unexpected action !!!"
	        end
	  	end

	  	def start_image path, args
	  		require 'fileutils'

	  		@config = {}.merge args.pop
			origin_path = path
			assets_path = "#{Knotz.base_dir}/data/images"

			Knotz.logger.info "file : #{origin_path}"
			Knotz.logger.info "dest : #{assets_path}"

			FileUtils.cp(origin_path, assets_path)

	  	end

	  	def read full_path
	  		raise unless File.exist? full_path
	  		File.read full_path
	  	end

	end

	
end

