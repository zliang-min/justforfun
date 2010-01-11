class Jekyllku::Updater
  def initialize(options = {})
    @site = Jekyll::Site.new Jekyll.configuration(options)
  end

  def process
    @site.process
  end
end
