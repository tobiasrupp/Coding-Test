class ConversionController < ApplicationController
    require 'xml'
    
  #... add some security
  
  def batch
    #check optional parameters
    if params[:destinations_path]
      destinations_path = params[:destinations_path]
      if !File.exists?(destinations_path) || File.directory?(destinations_path)
        render :text => "File #{destinations_path} does not exist."
        return
      end
    else  
      destinations_path = 'public/input/destinations.xml'
    end
    if params[:taxonomy_path]
      taxonomy_path = params[:taxonomy_path]
      if !File.exists?(taxonomy_path) || File.directory?(taxonomy_path)
        render :text => "File '#{taxonomy_path}' does not exist."
        return
      end
    else
      taxonomy_path = 'public/input/taxonomy.xml'
    end
    if params[:output_folder_path]
      @output_folder_path = params[:output_folder_path]
      if !File.exists?(@output_folder_path) && !File.directory?(@output_folder_path)
        render :text => "Output folder path '#{@output_folder_path}' does not exist."
        return
      end
      #add slash at the end of path 
      last_char = @output_folder_path.split('').last
      if last_char != "/"
        @output_folder_path << "/"
      end 
    else
      @output_folder_path = 'public/output/'
    end
    
    #read and parse source files
    parser = XML::Parser.file(taxonomy_path)
    @doc = parser.parse
    parser = XML::Parser.file(destinations_path)
    @destinations = parser.parse
    
    #speed up XPath computation on static documents
    @doc.order_elements! 
    @destinations.order_elements! 
    
    #get all destination elements
    @all_nodes = @doc.find("//node")
    @all_nodes.each do |node| 
      @node = node
      
      #get destination id
      attributes = @node.attributes
      @atlas_node_id = attributes.get_attribute('atlas_node_id')
      if @atlas_node_id == nil
        @atlas_node_id = attributes.get_attribute('geo_id')    
      end
    
      #get destination text
      @node.each_child do |element|
    	  if element.name == 'node_name'  	
    		  @node_name = element.content
    		  break
    	  end
      end
      if !@node_name 
        @node_name = "Text not found"
      end
      
      #get overview text of destination
      @overview = @destinations.find_first("//destination[@atlas_id=#{@atlas_node_id.value}]/introductory/introduction/overview")
      
      #get parent destination
      @parent_node = @node.parent
      parent_node_attributes = @parent_node.attributes
      @parent_atlas_node_id = parent_node_attributes.get_attribute('atlas_node_id')
      if @parent_atlas_node_id == nil
        @parent_atlas_node_id = parent_node_attributes.get_attribute('geo_id')    
      end
      
      #get parent destination text
      @parent_node.each_child do |element|
    	  if element.name == 'node_name'  	
    		  @parent_node_name = element.content
    		  break
    	  end
      end
      if !@parent_node_name 
        @parent_node_name = "Text not found"
      end
    
      #render output html and create new file at a specified path.
      html_text = render_to_string  
      file = File.new("#{@output_folder_path}#{@atlas_node_id.value}-#{@node_name}.html","w")
      file.write html_text
      file.close    
     end
     
    render :text => 'Conversion completed.'
  end
 
  def render_destination
    if !node_id = params[:id]
      node_id = '355064'
    end
    parser = XML::Parser.file('public/input/taxonomy.xml')
    @doc = parser.parse
    parser = XML::Parser.file('public/input/destinations.xml')
    @destinations = parser.parse
    
    #speed up XPath computation on static documents.
    @doc.order_elements! 
    @destinations.order_elements! 
    
    @node = @doc.find_first("//node[@atlas_node_id=#{node_id}]")
    @attributes = @node.attributes
    @atlas_node_id = @attributes.get_attribute('atlas_node_id')
    if @atlas_node_id == nil
      @atlas_node_id = @attributes.get_attribute('geo_id')    
    end
    
    #get destination text
    @node.each_child do |element|
    	if element.name == 'node_name'  	
    		@node_name = element.content
    	elsif element.name == 'node'
    	  @has_related_destinations = true 
    	end
    end
    if !@node_name 
      @node_name = "Text not found"
    end
    
    @overview = @destinations.find_first("//destination[@atlas_id=#{node_id}]/introductory/introduction/overview")
    
    @parent_node = @node.parent
    parent_node_attributes = @parent_node.attributes
    @parent_atlas_node_id = parent_node_attributes.get_attribute('atlas_node_id')
    if @parent_atlas_node_id == nil
      @parent_atlas_node_id = parent_node_attributes.get_attribute('geo_id')    
    end
    
    html_text = render_to_string
    
    # Create new file at a specified path.
    file = File.new("public/output/#{node_id}-#{@node_name}.html","w")
    file.write html_text
    file.close
  end
end
