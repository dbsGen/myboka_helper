require 'myboka_helpers/template_path'
require 'hashie'

module MybokaHelpers
  module Template
    module Controller
      def bk_template_path(path)
        TemplatePath.path(@content_template || @template, path)
      end
    end

    # 获得博客模板的 公共设置
    def public_settings
      if @public_settings.nil?
        @public_settings = Hashie::Mash.new current_user.blog_settings['public_settings']
      end
      @public_settings
    end

    # 获得博客模板的 单独设置
    def template_settings
      if @template_settings.nil?
        @template_settings = Hashie::Mash.new current_user.blog_settings[@template.name]
      end
      @template_settings
    end

    def current_template
      @content_template || @template
    end

    # 渲染一个显示模板
    def render_element(element)
      template = element.template
      #如果模板丢失就显示默认样式
      return raw("<p title='#{t('templates.error')}' style='background-color: red'>#{element.content}</p>") if template.nil?
      comment = template.type == 'comment' ? element.comment : nil
      @content_template = template
      @render_element = element

      @index ||= {}
      now = @index[template.name] || 0
      html = ''
      if now == 0 and
        html << "<div class=\"skim_#{template.name}_assets\">"
        html << _render_assets('skim')
        html << '</div>'
      end
      hash = {
          :id => "#{template.name}_#{now}",
          :element => element,
          :dynamic_path => TemplatePath.path(template),
          :template_info => template.description,
          :comment => comment
      }
      begin
        html << '<div class="skim_element">'
        html << render(
            :file => TemplatePath.skim_content(template) ,
            :locals => hash
        )
        html << '</div>'
      rescue StandardError => e
        html << "<div class='error'>We get a error : #{e}</div>"
      end
      @index[template.name] = now + 1
      @content_template = nil
      @render_element = nil
      raw html
    end

    # 渲染一个编辑模板
    def render_template_edit(template, index = 0)
      return '' if template.nil?
      content = ''
      if template.is_a?(Element)
        content = template.content
        template = template.template
      end
      @content_template = template
      html = _render_template(index, content, true)
      @content_template = nil
      raw html
    end

    # 渲染一个没有内容和删除按钮的编辑模板
    def render_template_edit_nr(template, index = 0)
      return '' if template.nil?
      @content_template = template
      html = _render_template(index, '')
      @content_template = nil
      raw html
    end

    private

    def _render_template(index, default, delete = false)
      html = ''
      template = current_template
      if index.to_i == 0
        html << "<div class=\"edit_#{template.name}_assets\">"
        html << _render_assets('edit')
        html << '</div>'
      end
      html << "<div class='edit_element' template='#{template.name},#{template.version}' for='edit_#{template.name}_#{index}'>"
      TemplatePath.get template unless TemplatePath.exist? template
      html << render(
          :file => TemplatePath.edit_content(template),
          :locals => {
              :id => "edit_#{template.name}_#{index}",
              :dynamic_path => TemplatePath.path(template),
              :template_info => Hashie::Mash.new(template.description),
              :default => default
          }
      )
      html << link_to('删除', 'javascript:void(0)', :id => 'remove_tag', :onclick => 'remove_tag(this)') if delete
      html << '</div>'
      html
    end

    def _render_assets(type)
      html = ''
      current_template.paths("#{type}_path") do |js, css|
        js.each do |v|
          html << bk_javascript_include_tag(v.path)
        end
        css.each do |v|
          html << bk_stylesheet_link_tag(v.path)
        end
      end
      html
    end
  end
end