class FilesController < ApplicationController
  def ls
    @files = Dir.glob("./*")
  end
end
