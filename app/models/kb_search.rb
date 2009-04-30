class KbSearch
  include Exceptions
  include CommonMethods
  
  attr_accessor :query, :noexist_terms, :escaped_query, :xml, 
    :results_list, :hashed, :rest_path
  
  def initialize(query='')
    @query = query
    @escaped_query = CGI::escape(@query)    
    @rest_path = 
      "/REST/v0.2/#{ConfigFile[:domain_class]}/search/" + 
      "#{ConfigFile[:audience]}?query=#{@escaped_query}&domain=#{ConfigFile[:domain]}"
  end
  
  def retrieve_results
    check_for_kb_errors
    process_results
    check_for_noexist_terms
  end
  
  def hashed
    @hashed ||= xml_to_hash['kbsearch']
  end

  def xml
    @xml ||= request_xml
  end
  
  def results?
    hashed['numResults'].to_i > 0
  end

  def process_results
    @results_list = extract_array_from_hash
    ensure_array_for_single_member
  end
  
  def extract_array_from_hash
    results? ? hashed['results']['result'] : nil
  end
  
  def ensure_array_for_single_member
    [results_list].flatten
  end
  
  def check_for_noexist_terms
    if hashed['noexist']
      @noexist_terms = process_noexist_terms
    end
  end

  def process_noexist_terms
    hashed['noexist'].split.each{|term|term.strip}.sort
  end
  
end
