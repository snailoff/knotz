class Relationship < ActiveRecord::Base
	belongs_to :knot, :foreign_key => "knot_id", :class_name => "Knot"
	belongs_to :piece, :foreign_key => "piece_id", :class_name => "Knot"
end
