class ConversionController < ApplicationController
    require 'rexml/document'
    include REXML
    
    require 'xml'
    
  #... add some security
  
  def libxml
  
    parser = XML::Parser.file('public/input/taxonomy.xml')
    @doc = parser.parse
    parser = XML::Parser.file('public/input/destinations.xml')
    @destinations = parser.parse
    
    #speed up XPath computation on static documents.
    @doc.order_elements! 
    @destinations.order_elements! 
    #@nodes = @doc.find_first('//node')
    #@node = @doc.root.node_type_name () 
    #@node_context = @node.context(namespaces=nil)
    
    @node = @doc.find_first('//node[@atlas_node_id=355611]')
    @attributes = @node.attributes
    @atlas_node_id = @attributes.get_attribute('atlas_node_id')
    if @atlas_node_id == nil
      @atlas_node_id = @attributes.get_attribute('geo_id')    
    end
    
    @overview = @destinations.find_first('//destination[@atlas_id=355611]/introductory/introduction/overview')
    
    @node.each_element do |element|
      node_type = element.node_type_name
      if node_type !='node_name'
        #@node_text = element.content
      else
        
      end
    end
    @parent_node = @node.parent
    parent_node_attributes = @parent_node.attributes
    @parent_atlas_node_id = parent_node_attributes.get_attribute('atlas_node_id')
    if @parent_atlas_node_id == nil
      @parent_atlas_node_id = parent_node_attributes.get_attribute('geo_id')    
    end
    @path = @node.path
    
    
    
  end
  def render_node
    if !node_id = params[:id]
      node_id = '355064'
    end
    parser = XML::Parser.file('public/input/taxonomy.xml')
    @doc = parser.parse
    parser = XML::Parser.file('public/input/destinations.xml')
    @destinations = parser.parse
    
    #speed up XPath computation on static documents
    @doc.order_elements! 
    @destinations.order_elements! 
    
    @node = @doc.find_first("//node[@atlas_node_id=#{node_id}]")
    @attributes = @node.attributes
    @atlas_node_id = @attributes.get_attribute('atlas_node_id')
    if @atlas_node_id == nil
      @atlas_node_id = @attributes.get_attribute('geo_id')    
    end
    
    @overview = @destinations.find_first("//destination[@atlas_id=#{node_id}]/introductory/introduction/overview")
    
    @parent_node = @node.parent
    parent_node_attributes = @parent_node.attributes
    @parent_atlas_node_id = parent_node_attributes.get_attribute('atlas_node_id')
    if @parent_atlas_node_id == nil
      @parent_atlas_node_id = parent_node_attributes.get_attribute('geo_id')    
    end
  end
  
  def batch
    #read and parse source files
    parser = XML::Parser.file('public/input/taxonomy.xml')
    @doc = parser.parse
    parser = XML::Parser.file('public/input/destinations.xml')
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
      file = File.new("public/output/#{@atlas_node_id.value}-#{@node_name}.html","w")
      file.write html_text
      file.close    
     end
     
    render :text => 'Conversion completed.'
    #render 'conversion/test'
  end
  
  def testo
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
    
    @nodes = @doc.find("//node")
    render 'conversion/test'
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
  
  def test
   
    file = File.open("public/input/destinations.xml", "rb")
    contents = file.read
    
    render :inline => contents
  end
  
  def convert_xml_to_html(destinations_url="public/input/destinations.xml",
                          taxonomy_url="public/input/taxonomy.xml",
                          output_folder_url="public/output/")

    #check if passing parameters works
   
    destinations = read_file(destinations_url)
    taxonomy = read_file(taxonomy_url)

    #parse xml

  

    xmlfile = File.new("public/input/taxonomy.xml")
    xmldoc = Document.new(xmlfile)

string = ""
    xmldoc.elements.each("definitions/src") do |element|
    			string = string + "[", element.name.to_s, "]"
    			element.each_recursive do |childElement|
    				string = string + "[", childElement.name.to_s, "]"
    			end
    		end




    render :text => string    
    
    #write file
    #File.open("test.txt","w") {|f| f.write('MyString') }
  end
  
  private
  def read_file(url)
    file = File.open(url, "rb")
    file.read
  end
  
  
end
