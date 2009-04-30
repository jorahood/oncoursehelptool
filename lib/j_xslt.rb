# this was taken almost verbatim from
# http://kfahlgren.com/blog/2007/03/02/borrowing-javas-xslt-support-for-ruby/

require 'java'
module JXslt
  include_class "javax.xml.transform.TransformerFactory"
  include_class "javax.xml.transform.Transformer"
  include_class "javax.xml.transform.stream.StreamSource"
  include_class "javax.xml.transform.stream.StreamResult"
  include_class "java.lang.System"
  include_class "java.io.StringWriter"
  include_class "java.io.StringReader"
  class SaxonProc

    def initialize
      System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl")
      @tf = TransformerFactory.newInstance
    end

    def transform(xslt_file,xml)
      transformer = @tf.newTransformer(StreamSource.new(xslt_file))
      out = StringWriter.new
      transformer.transform(StreamSource.new(StringReader.new(xml)), StreamResult.new(out))
      out.toString
    end

    def file_transform(xslt,infile,outfile)
      transformer = @tf.newTransformer(StreamSource.new(xslt))
      transformer.transform(StreamSource.new(infile), StreamResult.new(outfile))
    end

  end
end 
