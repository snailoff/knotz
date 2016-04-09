class Knot < ActiveRecord::Base
	attr_accessor :knots

	has_many :relations_to, :foreign_key => "knot_id", :class_name => "Relationship"
	has_many :relations_from, :foreign_key => "piece_id", :class_name => "Relationship"

	has_many :linked_to, :through => :relations_to, :source => :piece
	has_many :linked_from, :through => :relations_from, :source => :knot

	has_many :attatch
end
