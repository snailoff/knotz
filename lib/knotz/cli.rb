require "thor"
require "daemons"
require "listen"

module Knotz
	class CLI < Thor

		desc "listen (start|stop|restart|status)", "starts knotz"
		long_desc <<-LONGDESC
			'knot' is your text file to build. specify pull path or relative path from 'lib'.
		LONGDESC

		def listen action 
			ARGV[0] = action

			Daemons.run_proc('listen.rb', {:log_output => true}) do
				Knotz.logger.info "Knotz version: #{Knotz::VERSION}"

				Knotz.initConfig

				listener = Listen.to(Knotz.mainConfig[:knot_path]) do |modified, added, removed|
					puts "modified absolute path: #{modified}"
					puts "added absolute path: #{added}"
					puts "removed absolute path: #{removed}"
					Knotz.start(added, :type => :ADDED) unless added.empty?
					Knotz.start(modified, :type => :MODIFIED) unless modified.empty?
					Knotz.start(removed, :type => :REMOVED) unless removed.empty?
				end

				listener.start # not blocking
				sleep
			end
			
		end
	end

	def self.base_dir
		File.dirname(__FILE__).sub(/^(.*?knotz).*?$/, "\\1")
	end
	
end