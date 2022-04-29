# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      class Blogs < Grape::API
        # helpers ::API::V2::Admin::Helpers

        post '/blogs' do
          # admin_authorize! :write, ::Blogs

          blog = Blog.new(params)
          if @blog.save
            present blog, with: API::V2::Admin::Entities::Blog
          else
            body errors: blog.errors.full_messages
            status 422
          end
        end

        get '/blogs' do
          blogs = Blog.all
          present paginate(blogs), with: API::V2::Admin::Entities::Blog
        end
      end
    end
  end
end