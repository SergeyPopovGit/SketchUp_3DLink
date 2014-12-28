# Definishion 3Ddesktop class as extenction for Sketchup

require 'sketchup.rb'
require 'extensions.rb'


class Desktop3D 
			######## define system constant
$D3D_DICTIONARY = 'link_dictionary' 	#---define dictionary for link attributs
$D3D_ATTRIBUT = 'file_path'			#---define attributs name
TOOLBAR = 'Link_Tools'			#---define tool bar name
			######## определение параметров класса


	def initialize
		puts "Init Desktop3D v 0.6 class start"
		
		############# objects initialization
		init_objects
		
		puts "Init Desktop class finish"
	end
   	
	def init_objects
			puts "member objects initialization start"
			
			######### Init_variable
			@path = File.dirname(__FILE__) #фиксация пути расположения файла объявления класса
			@linked_file_path = nil;	#обнуление пути к файлу который будет пристегнут к объекту
			@selected_entytis = Sketchup::Selection  #добавляем выделенные модели
			#@play_command
			@play_link_flag = 0 #reset play flag
			
			######## create my tools panel 
			@toolbar = UI::Toolbar.new TOOLBAR #создание инструментальной панели
	
			######### Create commands end toolbar
			create_link_command
			create_play_command
						
			puts "member objects initialization end"
	end
	
	def create_link_command # creating commands objects
	
	#########create  linking command
															###### command proc ########
		linking_command = UI::Command.new("Start_link"){ start_linking }     ####
															############################
				
		linking_command.menu_text = "Linking"
		###### set swich on/off proc for icon
			linking_command.set_validation_proc  {
					#activate if current model has selected items
				if Sketchup.active_model.selection.length == 0 
					MF_GRAYED
				else
					MF_ENABLED
				end
		}
			
		#########adding command to tolbar
			linking_command.small_icon = "Link.png"
			linking_command.large_icon = "Link.png"
			linking_command.status_bar_text = "Привязка обьекта к файлу"
			@toolbar.add_item linking_command
			@toolbar.show
	
	end
	
	
	def create_play_command
		#########create start linking command
													###### command proc ########
			@play_command = UI::Command.new("Play_link"){ play_link }          ####
													############################
		###### set swich on/off proc for icon
			@play_command.set_validation_proc  {
				#activate if  link tool play 
				if @play_link_flag == 1 then  MF_CHECKED else  MF_UNCHECKED end
		}
		
		########## Set command to toolbar
			@play_command.small_icon = "Button Play.png"
			@play_command.large_icon = "Button Play.png"
			@play_command.status_bar_text = "Play links"
			@play_command.menu_text = "Play links"

		
		########## Adding command to toolbar
			@toolbar.add_item @play_command
			@toolbar.show
		end 
		
	def start_linking #Start link process
			puts "start_linking start"
			
			####### Check objects 
			@selected_entytis = Sketchup.active_model.selection
			if @selected_entytis.empty?
					UI.messagebox("Select object") 
					return  end

			####### Input path to file
			@linked_file_path = UI.openpanel( "Link to", @path, "")
				######## check objects file_path
						unless  @linked_file_path 	#if file not choice
									UI.messagebox("Select file to link") 
									return  end
			
			######## Link file to selected objects
			link_file_to_selected_objects
			
			
			puts "start_linking finish"
	end
	
	
	
	def link_file_to_selected_objects 
			
			
			######## selections entity loop
			@selected_entytis.each do |current_entity|
				###### check entity type
				if current_entity.is_a?(Sketchup::Group) or \
					current_entity.is_a?(Sketchup::ComponentInstance)
					######### reset flags 
					skip_flag = IDYES
				
					######### set entyti attributs 
										
						######### check entyti 
						current_attribut = current_entity.get_attribute $D3D_DICTIONARY, $D3D_ATTRIBUT
						if current_attribut 
								skip_flag = UI.messagebox("Change link #{current_entity.to_s}", MB_YESNOCANCEL) 	
								if skip_flag == IDCANCEL
									return end
						end
						
					######### set entyti attributs 
					if skip_flag == IDYES	
					current_entity.set_attribute $D3D_DICTIONARY, $D3D_ATTRIBUT, @linked_file_path
							puts "Link #{current_entity.to_s} to #{@linked_file_path}"
				end
				end
			end
			
	end	
	
	def play_link
		
		if @play_link_flag == 1
		###### stop play link 
				@play_command.status_bar_text = "Stop Play"
				@play_command.menu_text = "Stop Play"
				@play_link_flag = 0
				
		#######  stop_play
				Sketchup.send_action('selectSelectionTool:')
		else 
		
		puts "Start play links"
		###### start play link
			@play_command.status_bar_text = "Play links"
			@play_command.menu_text = "Play links"
			
			@play_link_flag = 1
			
		#######  start_play
				Sketchup.active_model.select_tool PlayLink.new

		
		end
	end
	
	
	
end	

class PlayLink
	def initialize
	##### define var
		@selected_entytis = Sketchup.active_model.selection
		
		@path = File.dirname(__FILE__)
		@linked_cursor = UI.create_cursor(File.join(@path,'linked.png'),0,0)
		#puts "Cursor_ID #{@linked_cursor}"
		
		@empty_cursor = UI.create_cursor(File.join(@path,'empty.png'),0,0)
		#puts "Cursor_ID #{@empty_cursor}"
		
		@attr_value = ""
	end
	
	def onMouseMove(flags,x,y,view)
				
				###############
				## Best Pick ##
				###############
				ph=view.pick_helper
				ph.do_pick x,y
				current_best=ph.best_picked
			
				##### update tooltip text
				if @attr_value then view.tooltip = @attr_value end	 #update if attr_value define 
				
				#### If select entity change
			if current_best != @best	# Check  
				@best = current_best	#update if object change
											
				###### all highlight off 
				@selected_entytis.clear
			
				###### check entity type end select
				if @best.is_a?(Sketchup::Group) or \
					@best.is_a?(Sketchup::ComponentInstance)
					
					
				###### Highlight current entity
					@selected_entytis.add(@best)
					
				###### set status bar end cursor

					@attr_value = @best.get_attribute $D3D_DICTIONARY, $D3D_ATTRIBUT # get atrtribut value
					
					if @attr_value 
							Sketchup.set_status_text(@attr_value)
							view.tooltip = @attr_value
							
					end
				
				#####    	
				else 
						Sketchup.set_status_text("")
						@attr_value = nil
							
				end 
			end	
			
	end #def
	
	def onSetCursor()
		  if @attr_value
			  UI.set_cursor(@linked_cursor)
		  else
			  UI.set_cursor(@empty_cursor)
		  end
	end
	
	def onLButtonDown(flags,x,y,view)
				

	end
	
	def onLButtonDoubleClick(flags,x,y,view)
				
			####### Open link
			if @best.is_a?(Sketchup::Group) or \
					@best.is_a?(Sketchup::ComponentInstance)
					
				####### openfile
				UI.openURL(@attr_value)
		
			end
	end
	
end
	