module Knotz
	class Template
		def initialize config
			Knotz.logger.info ""
			Knotz.logger.info "=== Template ==="
			@config = config
			@tpl = File.read Knotz.mainConfig[:template_path]
		end

		def render 
			knotFrom = !@config[:parsed][:knot_from].empty? ? "<p class=\"from\"><span class=\"glyphicon glyphicon-chevron-left\" aria-hidden=\"true\"></span> #{@config[:parsed][:knot_from]}</p>" : ""
			knotTo = !@config[:parsed][:knot_to].empty? ? "<div class=\"to\"><span class=\"glyphicon glyphicon-chevron-right\" aria-hidden=\"true\"></span>#{@config[:parsed][:knot_to]}</div>" : ""

			@tpl.sub! '__TITLE__', @config[:parsed][:title] 
			@tpl.sub! '__BODY__', @config[:parsed][:body]
			@tpl.sub! '__KNOT_FROM__', knotFrom
			@tpl.sub! '__KNOT_TO__', knotTo
			@tpl.sub! '__PARSED_DATE__', DateTime.now.strftime("%Y%m%d %H%M%S").gsub(/0/, 'o')

			@config[:html] = @tpl
		end
	end
end