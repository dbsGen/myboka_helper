# 与资源有关的view helpers
require 'myboka_helpers/config'
require 'pathname'

module MybokaHelpers
  module Resources

    # 插入脚本文件
    # 用于插入模板中使用的脚本
    def bk_javascript_include_tag(*sources)
      insert_static_url sources
      javascript_include_tag *sources
    end

    # 插入样式文件
    # 同上
    def bk_stylesheet_link_tag(*sources)
      insert_static_url sources
      stylesheet_link_tag *sources
    end

    # 加入一个动态脚本
    # 会以轮询的形式 运行check_code
    # 当check_code 是false的时候运行脚本
    def javascript_defer_tag(check_code, path, ops = {})
      render partial: 'myboka_helpers/script', locals: {
          options:ops,
          insert_content_path:path,
          check_code:check_code
      }
    end

    # 获取静态文件的位置
    def assets_url(*args)
      if args.size == 2
        template, path = args
      else
        path = args.first
        template = current_template
      end
      "#{::MybokaHelpers::Config['static_temp_site']}/#{template.name}-#{template.version}/#{path}"
    end

    alias :assets_path :assets_url

    # 读取代码
    def load_script(path)
      File.open path do |f|
        eval(f.read)
      end
    end

    def dynamic_path
      TemplatePath.path(current_template)
    end

    private

    def insert_static_url(*sources)
      url = sources.first.shift
      path = Dir["#{Rails.root}/public/p_assets/*/#{url}"].first
      logger.info "#### : #{url} + #{path}"

      if (template = current_template) and !path
        url = "#{Config['static_temp_site']}/#{template.folder_name}/#{url}" if url[/^\w+:\/\//].nil?
        sources.first.unshift url
      elsif path
        sources.first.unshift path.gsub("#{Rails.root}/public/", '/')
      end
      sources
    end
  end
end