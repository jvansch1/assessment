module Api
  class PingsController < ApplicationController
    def ping
      render json: JSON.pretty_generate({ success: true })
    end
  end
end
