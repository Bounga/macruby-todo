#
#  Todo.rb
#  MacRubyTodo
#
#  Created by Nicolas Cavigneaux on 19/05/09.
#  Copyright (c) 2009 Bounga. All rights reserved.
#

class Todo
	attr_accessor :desc, :created_on, :done

	def initialize(desc, created_on=Time.now, done=false)
		@desc = desc
		@created_on = created_on.strftime('%Y/%m/%d')
		@done = done
	end
	
	def encodeWithCoder(coder)
		coder.encodeObject @desc, forKey:"desc"
		coder.encodeObject @created_on, forKey:"created_on"
		coder.encodeObject @done, forKey:"done"
	end
	
	def initWithCoder(decoder)
		@desc = decoder.decodeObjectForKey("desc")
		@created_on = decoder.decodeObjectForKey("created_on")
		@done = decoder.decodeObjectForKey("done").boolValue
		
		return self;
	end
	
	def inspect
		"#{@desc} #{@created_on} #{@done}"
	end
end
