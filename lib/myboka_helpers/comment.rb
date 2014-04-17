# 与评论有关的helpers

module MybokaHelpers
  module Comment
    # 渲染一个评论
    def render_comment(comment, reply_count = 0)
      html = ''
      @comments_index ||= {}

      html << "<div class='box'>"
      html << simple_comment_tag(comment, reply_count)
      html << '</div>'

      raw html
    end

    # 获得元素评论的路径
    def element_comment_path(*sources)
      h = sources.last
      if h.is_a? Hash
        h[:element_id] = @render_element.id
      else
        sources << {element_id: @render_element.id}
      end
      e_comments_path(*sources)
    end

    # 渲染评论中的操作按钮
    def comment_action_tag(comment)
      action_tags comment
    end

    # 添加评论
    def render_add_comment
      render partial: 'myboka_helpers/add_comment'
    end

    #渲染评论
    def render_comments
      render partial: 'myboka_helpers/comments'
    end

    private

    def action_tags(comment)
      html = '['
      html << link_to(t('comments.reply'), '#article-replay',
                      :onclick => "reply('#{comment.id}', #{comment.flood || 0})")
      html << ']'
      if login?
        html << '&nbsp;['
        html << link_to('举报', 'javascript:void(0)',
                        class: 'report-comment',
                        'data-id' => comment.id,
                        'data-display' => "##{comment.flood}",
                        'data-url' => account_reports_path)
        html << ']'
      end
      raw html
    end

    def simple_comment_tag(comment, reply_count = 0)
      @comments_index["#{comment.id}"] = true
      render(
          :partial => 'myboka_helpers/comment',
          :locals => {
              :reply_to => comment.reply_to,
              :comment => comment,
              :author => comment.creater,
              :reply_count => reply_count
          }
      )
    end
  end
end