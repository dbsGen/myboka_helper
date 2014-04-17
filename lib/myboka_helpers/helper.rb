#   主程序中的方法
#   current_user 调用当前用户
#   time_ago_in_words in default view helper
require 'myboka_helpers/comment'
require 'myboka_helpers/content'
require 'myboka_helpers/resources'
require 'myboka_helpers/template'
require 'myboka_helpers/users'

module MybokaHelpers
  module ViewHelper
    include MybokaHelpers::Users
    include MybokaHelpers::Comment
    include MybokaHelpers::Content
    include MybokaHelpers::Resources
    include MybokaHelpers::Template
  end

  module ControlHelper
    include MybokaHelpers::Template::Controller
    include MybokaHelpers::Users::Controller
  end
end