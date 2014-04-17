# 用户有关的view helpers
require 'myboka_helpers/config'

module MybokaHelpers
  module Users

    module Controller
      # 获得当前用户
      def show_liked?
        if current_user
          following_ids = current_user.attributes['following_ids'] || []
          following_ids << current_user.id
          Article.where(:creater_id.in => following_ids).count > 0
        else
          false
        end
      end
    end

    # 获得用户头像的url
    # 头像服务使用的是mingp  https://mingp.net/
    def avatar_url(user, exp = nil)
      if user.nil?
        key = 'none'
      else
        email = user.is_a?(User) ? user.email : user
        key = Rails.cache.fetch ['string', 'user', 'key', email] do
          Digest::MD5.hexdigest(email)
        end
      end
      "#{Config['carte_site']}public/avatar/#{key}#{exp.nil? ? '' : '?' + URI.encode_www_form({expression: exp})}"
    end

    # 获得用户的link的地址
    # 现在并没有用户个人页面所以用的是博客地址
    def link_with_user(user)
      domain = user.domains.first
      domain.nil? ? "javascript:alert('这个用户还没有开通博客.')" : "http://#{domain.word}.#{CONFIG.host_domain.first}"
    end

    # 用户名的html
    # ops不为空会作为标签属性渲染到页面上
    def name_tag(user, ops = {})
      return '没有这个用户' if user.nil?
      url = link_with_user(user)
      key = Rails.cache.fetch ['string', 'key', user] do
        Digest::MD5.hexdigest(user.email)
      end
      hash = {
          'mp-key' => key,
          'mp-display' => escape_once("(#{link_to("#{user.name}@Myboka", url, target: url[/^http:/].nil? ? '_self' : '_blank')})")
      }
      ops.delete(:hidden_liked) unless ops[:hidden_liked]
      hash.merge!(ops)
      if current_user.nil?
        name = user.nickname
      else
        if current_user == user
          hash[:no_like] = true
          hash[:hidden_liked] = true
        end
        name = name_with_heart(user)
        hash[:onload] = 'window.mingp.onload(this)'
        hash[:onmiss] = 'window.mingp.onmiss(this)'
        hash[:onshow] = 'window.mingp.onshow(this)'
        hash['data-url'] = followers_path(user)
      end
      hash['target'] = '_blank'
      link_to(name || '无名氏', url, hash)
    end

    # 用户之间的关系
    # 关注： liked
    # 不关注： unlike
    # 非正常: none
    def relation(user)
      if current_user.nil? or user.nil?
        'none'
      else
        current_user.follow?(user) ? 'liked' : 'unlike'
      end
    end

    #是否赞过
    def check_liked(article)
      return current_user.liked_article_ids.include?(article.id) if login?
      false
    end

    private

    # 获得带桃心的用户名
    def name_with_heart(user)
      current_user.follow?(user) ? raw("#{user.nickname}<span class='icon-heart' style='color:red'></span>") : user.nickname
    end
  end

end