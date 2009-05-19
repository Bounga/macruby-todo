#
#  TodoController.rb
#  MacRubyTodo
#
#  Created by Nicolas Cavigneaux on 14/05/09.
#  Copyright (c) 2009 Bounga. All rights reserved.
#

require 'Todo'

class TodoController < NSWindowController

	attr_accessor :tableView, :textField, :removeButton, :items_count
	
	# Initializing items
	def awakeFromNib
		@items = []
		@items = loadFromDisk
		@items = sortedItems
		
		updateItemsCount
	end
	
	#########################
	# Delegates for TableView
	#########################
	
	# Return current row count in TableView
	def numberOfRowsInTableView(table)
		@items ? @items.size : 0
	end
	
	# Feed the TableView
	def tableView(table, objectValueForTableColumn:column, row:row)
		case column.headerCell.stringValue
		when 'Items'
			@items[row].desc
		when 'Created on'
			@items[row].created_on
		when 'Done'
			@items[row].done
		end
	end
	
	# Activate remove button if a row is selected
	def tableViewSelectionDidChange(notification)
		updateItemsCount
		@removeButton.enabled = true
	end
	
	# Ensure done items can't be edited
	def tableView(table, shouldEditTableColumn:column, row:row)
		@items[row].done ? false : true
	end
	
	# Save on-the-fly changes in TableView to the datasource
	def tableView(table, setObjectValue:object, forTableColumn:column, row:row)
		case column.headerCell.stringValue
		when 'Items'
			@items[row].desc = object
		when 'Done'
			@items[row].done = !@items[row].done
			@items = sortedItems
			@tableView.reloadData
		end
	end
	
	#########
	# Actions
	#########
	
	# Save state
	def save(sender)
		saveToDisk
	end
	
	# Add an item to the table view
	def addItem(sender)
		unless @textField.stringValue == "" or @textField.stringValue.nil?
			@items.unshift(Todo.new(@textField.stringValue))
			@textField.stringValue = ''
			@tableView.reloadData
		end
	end
	
	# Remove an item from the table view
	def removeItem(sender)
		@items.delete_at(@tableView.selectedRow)
		@tableView.reloadData
		@tableView.deselectAll(self)
		@removeButton.enabled = false
	end
	
	#########
	# Helpers
	#########
	
	private
	
	# Get save path
	def getPath
		folder = File.expand_path("~/Library/Application Support/MacRubyTodo/")
  
		fileManager = NSFileManager.defaultManager

		fileManager.createDirectoryAtPath(folder, attributes: nil) if fileManager.fileExistsAtPath(folder) == false
    
		fileName = "todos.mrt"
  		path = File.join(folder, fileName)
	end
	
	def saveToDisk
		rootObject = {}
    	rootObject.setValue(@items, forKey:"items")
	
		NSKeyedArchiver.archiveRootObject(rootObject, toFile: getPath)
	end
	
	# Load items form disk
	def loadFromDisk
		path = getPath
		values = []
		
		if File.exists?(path)
			rootObject = NSKeyedUnarchiver.unarchiveObjectWithFile(getPath)
			values = rootObject.valueForKey("items")
		end

		return values
	end
	
	# Sort items by done status (not done first)
	def sortedItems
		@items.sort_by { |i| i.done.to_s }
	end
	
	# Update done / not done items count label
	def updateItemsCount
		done_items = @items.select { |i| i.done == false }.size
		
		@items_count.stringValue = "#{@items.size} items - #{done_items} left"
	end
end
