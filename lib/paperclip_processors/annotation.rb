module Paperclip
  class Annotation < Thumbnail
 
    attr_accessor :annotation_text
 
    def initialize(file, options = {}, attachment = nil)
      super
 
      @geometry             = options[:geometry]
      @annotation_text      = options[:annotation_text]
      @annotation_font_size = (options[:annotation_font_size] or 32)
      @annotation_position  = (options[:annotation_position] or 'SouthEast')
      @created_at           = attachment.instance.created_at rescue nil      
    end
 
    def transformation_command
      trans = []
 
      if not @annotation_text.nil? and not @annotation_text.empty?
        unless @created_at
          filename = file.path
          meta = MiniExiftool.new filename
          @created_at = if meta['datecreated']
            photo["datecreated"].split(":").join("-").to_date
          else
            meta["createdate"] || File.mtime(filename)
          end     
          
        end
        @created_at = @created_at.strftime("%d/%m/%Y %H:%M") rescue ''        
        trans << "-gravity #{@annotation_position} -geometry +0+0"
        trans << "-pointsize #{@annotation_font_size}"
        trans << "-stroke '#000C' -strokewidth 2 -annotate 0 '#{@created_at}'"
        trans << "-stroke none -fill GoldenRod -annotate 0 '#{@created_at}'"
      end
 
      super + trans
    end
  end
end