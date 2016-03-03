class OccurencesController < ApplicationController
  def create
    Occurence.make_summit_request
  end
end
