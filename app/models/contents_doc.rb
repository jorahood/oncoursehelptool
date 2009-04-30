class ContentsDoc < KbDoc
  include CommonMethods

  def initialize
    docid = ConfigFile[:contents_docid]
    super(docid)
  end

  def transform_xml_to_html
    full_page = super
    /(<ul>.+<\/ul>)/m =~ full_page
    $1
  end
end
