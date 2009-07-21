# Author::      Eli Fox-Epstein, efoxepstein@wesleyan.edu
# Author::      Dimitar Gochev, dimitar.gochev@trincoll.edu
# Copyright::   Humanitarian FOSS Project (http://www.hfoss.org), Copyright (C) 2009.
# License::     http://www.gnu.org/copyleft/lesser.html GNU Lesser General Public License (LGPL)

class HomeController < ApplicationController
  
  before_filter :foo
  
  def foo
    logger.info '^'*100
    logger.info action_name
    logger.info controller_name
    logger.info params.inspect
    return true
  end
  
  def index
  end
  
  def show
    while true
      puts 'foo'
    end
    logger.info '#'*100
    render params[:page]
  end
  
  def terms
    
  end
  
end
