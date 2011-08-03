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
    
    @node = @doc.find_first('//node[@atlas_node_id=355064]')
    @attributes = @node.attributes
    @atlas_node_id = @attributes.get_attribute('atlas_node_id')
    if @atlas_node_id == nil
      @atlas_node_id = @attributes.get_attribute('geo_id')    
    end
    
    @overview = @destinations.find_first('//destination[@atlas_id=355064]/introductory/introduction/overview')
    
    @node.each_element do |element|
      node_type = element.node_type_name
      if node_type !='node_name'
        #@node_text = element.content
      else
        
      end
    end
    @parent_node = @node.parent
   
    @path = @node.path
    
    
    
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
