module HomeHelper
  def feeds_for name
    @feeds[name] rescue []
  end
  def user_for name
    feeds_for(name)[0]["user"]
  end
end
