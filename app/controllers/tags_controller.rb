class TagsController < AuthorizedController
  def index
    @tags = @instance.tags.paginate(:all, :page => params[:page], :per_page => 20).sort{|a,b|a.name<=>b.name}
    return with_rejection unless @current_user.can? :list => @tags
  end

  def show
    @tag = @instance.tags.find(params[:id], :include => [:groups, :updates])
    return with_rejection unless @current_user.can? :show => @tag
  end

  def destroy
    @tag = @instance.tags.find(params[:id])
    return with_rejection unless @current_user.can? :destroy => @tag
    @tag.destroy
    flash[:notice] = t('notice.tag.destroyed')
    redirect_to :back
  end

  def create_bulk
    tags = params[:tags].split(',').collect {|t| t.strip}.select {|t| t.length > 0}
    tags.each do |tag_name|
      Tag.create(:name => tag_name, :instance => @instance)
    end
    redirect_to :back
  end
end

