# 与内容有关的helpers

require 'nokogiri'

module MybokaHelpers
  module Content
    module Controller
      # 内容摘要
      def text_clip(content, limit = 140)
        return '' if content.nil?
        images = []
        doc = Nokogiri::HTML(content)
        doc.css('img').each do |img|
          images << img
        end
        c = strip_tags(content)
        text = c.length > limit ? "#{c[0..limit]}..." : c
        if block_given?
          yield((text.nil? or text.length == 0 ? '' : text), images)
        else
          res = (text.nil? or text.length == 0) ? '' : "#{text} <br/>"
          images.each {|img| res << img.to_s}
          res
        end
      end
    end

    # 为内容加上引用
    def add_quote(element, quote_info = nil)
      if element.is_a? String
        content = element
      else
        content = element.content
        quote_info = element.quote_info
      end
      nc = String.new(content)
      content.scan(ID_REGEXP) do |match|
        name = match[1..-1]
        id = quote_info[name]
        begin
          user = User.find id
        rescue StandardError => _
          user = nil
        end
        if user
          #DONE 这里需要补全地址
          html = name_tag(user)
          nc.sub!(match, html)
        end
      end
      nc
    end

    # 渲染文章内容
    def render_article_content
      html = ''
      @article.elements.each do |element|
        html << render_element(element)
      end
      raw html
    end

    #renders
    #render_content 渲染内容layout中使用
    #render_object 渲染列表的时候的单个对象爱那个,
    #   @params path 路径
    #   @params header 是否是头部
    #   @params object 需要渲染的对象
    def render_content
      render file: @content_path
    end

    def render_layout(ops = {})
      layout = ops.delete :layout
      @content_path = ops.delete :file
      ops[:file] = bk_template_path(layout)
      render ops
    end

    # 时间
    def time_progress(time)
      str = time.strftime('%Y-%m-%d')
      if str == Time.now.strftime('%Y-%m-%d')
        str = time_ago_in_words(time)
      end
      str
    end
  end
end