require "myboka_helpers/version"
require 'myboka_helpers/helper'
require 'myboka_helpers/config'


module MybokaHelpers
  class Railtie < Rails::Railtie
    initializer 'brighter_planet_layout.add_paths' do |app|

      ::ActionView::Base.send :include, MybokaHelpers::ViewHelper
      class ::ActionController::Base
        append_view_path "#{Pathname.new(File.dirname(__FILE__)).realpath}/myboka_helpers/views"
        include MybokaHelpers::ControlHelper
        helper MybokaHelpers::ControlHelper
      end
    end
  end
end
