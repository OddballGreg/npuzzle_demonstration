class NpuzzleController < ApplicationController
  def index
    @results = NpuzzleSolver.resolve
  end
end
