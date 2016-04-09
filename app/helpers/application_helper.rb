module ApplicationHelper
	def zeroToO(datetime) 
		datetime.to_s.gsub(/0/, "o")
	end
end
