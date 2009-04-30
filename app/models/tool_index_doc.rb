class ToolIndexDoc < KbDoc
  include CommonMethods
  
  def initialize
    docid = ConfigFile[:tool_index_docid]
    super(docid)
  end
  
  def lookup(tool_name)
    retrieve_text
    find_key(tool_name)
  end
  
  def find_key(tool_name)
    tool_names = hashed['document']['kbml']['body']['dl']['dt']
    docids = hashed['document']['kbml']['body']['dl']['dd']
    tool_names.each_with_index do |name,i|
      if name == tool_name
        return docids[i]
      end
    end
    return ConfigFile[:default_docid]
  end  

end
