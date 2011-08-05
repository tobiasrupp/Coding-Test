desc "Generates hmtl pages from destination source files"
task :convert => :environment do
  require 'xml'
  start_time = Time.now
  
  #check optional parameters
  destinations_path = ENV["DEST_PATH"]
  taxonomy_path = ENV["TAX_PATH"]
  output_folder_path = ENV["OUT_PATH"]
   
  if destinations_path
    if !File.exists?(destinations_path) || File.directory?(destinations_path)
      puts "File #{destinations_path} does not exist."
      exit
    end
  else  
    #default path
    destinations_path = 'public/input/destinations.xml'
  end
  if taxonomy_path
    if !File.exists?(taxonomy_path) || File.directory?(taxonomy_path)
      puts "File '#{taxonomy_path}' does not exist."
      exit
    end
  else
    #default path
    taxonomy_path = 'public/input/taxonomy.xml'
  end
  if output_folder_path
    if !File.exists?(output_folder_path) && !File.directory?(output_folder_path)
      puts "Output folder path '#{output_folder_path}' does not exist."
      exit
    end
    #add slash at the end of path 
    last_char = output_folder_path.split('').last
    if last_char != "/"
      output_folder_path = output_folder_path.dup
      output_folder_path << "/"
    end 
  else
    #default path
    output_folder_path = 'public/output/'
  end

  #read and parse source files
  begin
    parser = XML::Parser.file(taxonomy_path)
    taxonomy = parser.parse
    parser = XML::Parser.file(destinations_path)
    destinations = parser.parse
  rescue => exc
    exit
  end
  
  #speed up XPath computation on static documents
  taxonomy.order_elements! 
  destinations.order_elements! 
  
  #read all destination elements
  all_nodes = taxonomy.find("//node")
  #first_time = true
  file_count = 0
  action_view = ActionView::Base.new(Rails::Configuration.new.view_path) #required to render html
  logger = Logger.new("#{output_folder_path}_batch.log", shift_age = 'weekly')
  logger.info("#{start_time.to_datetime.strftime("%a, %d %b %Y, %T").squeeze(' ')} - Batch job started")
  all_nodes.each do |node| 
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
    
    #get destination overview text
    overview_element = destinations.find_first("//destination[@atlas_id=#{@atlas_node_id.value}]/introductory/introduction/overview")
    @overview = overview_element.content
    if !@overview
      @overview = "Text not found"
    end
    
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
  
    #render output html and create new file at specified path
    html_text = action_view.render(:partial => 'conversion/destination',
              :locals => {:node_name => @node_name, :parent_node_type => @parent_node.name,
                          :parent_atlas_node_id => @parent_atlas_node_id,
                          :parent_node_name => @parent_node_name,
                          :node => @node,
                          :atlas_node_id => @atlas_node_id,
                          :overview => @overview})
    file_name = "#{output_folder_path}#{@atlas_node_id.value}-#{@node_name}.html"
    file = File.new(file_name,"w")
    file.write html_text
    file.close    
    
    #write log entry
    file_count += 1
    logger.info("#{get_time_stamp} - Created #{file_name}")
  end
  end_time = Time.now
  job_duration = end_time - start_time 
  logger.info("#{get_time_stamp} - Batch completed. #{file_count} files created, Duration: #{job_duration}")
  logger.info("")
  puts "Conversion completed. #{file_count} files created, log: #{output_folder_path}_batch.log"
  puts "Duration: #{job_duration}"
end

def get_time_stamp
  time = Time.now
  time.to_datetime.strftime("%a, %d %b %Y, %T").squeeze(' ')
end