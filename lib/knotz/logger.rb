
module Knotz
  def self.logger
    @logger ||= Logger.new(STDOUT)

    @logger.formatter = proc { |severity, datetime, progname, msg|
      file = caller[4].sub /^.*\/(.*?)$/, "\\1"
      "#{severity.rjust(8)} #{file.rjust(40)} -- : #{msg}\n"
    }

    @logger
    end

  def self.logger=(logger)
    @logger = logger
  end
end
