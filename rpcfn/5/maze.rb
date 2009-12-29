class Maze
  START_POINT_MARKER = 'A'.freeze
  END_POINT_MARKER   = 'B'.freeze
  INFINITE           = (1.0 / 0.0).freeze

  class Cell
    WALL = '#'.unpack('c').first.freeze

    attr_reader :maze, :x, :y, :type

    def initialize(maze, x, y)
      @maze = maze
      @x, @y = x, y
      @type = maze.at(x, y)
    end

    def east;  @east  ||= maze.cell(self.x + 1, self.y) end

    def south; @south ||= maze.cell(self.x, self.y + 1) end

    def west;  @west  ||= maze.cell(self.x - 1, self.y) end

    def north; @north ||= maze.cell(self.x, self.y - 1) end

    def neighbors(navigable_only = true)
      [:east, :south, :west, :north].inject([]) do |neighbors, direction|
        (cell = send direction) &&
        (!navigable_only || cell.navigable?) &&
        neighbors << cell || neighbors
      end
    end

    def navigable?
      type != WALL
    end

    def eql?(other)
      other.is_a?(Cell)  &&
      maze == other.maze &&
      x == other.x &&
      y == other.y
    end

    def to_s
      "(#{x}, #{y})"
    end

    alias inspect to_s
  end # Cell

  def initialize(maze_string)
    @cells = {}
    parse maze_string
  end

  def solvable?
    steps != 0
  end

  def steps
    @steps ||= (step = process) == INFINITE ? 0 : step
  end

  def cell(x, y)
    @cells.has_key?([x, y]) ? @cells[[x, y]] :
      @cells[[x, y]] = exists?(x, y) ? Cell.new(self, x, y) : nil
  end

  def at(x, y)
    x < 0 || y < 0 ? nil : (row = @maze[y]) && row[x]
  end

  private
  def parse(maze_string)
    y = -1
    start_axes = end_axes = nil
    @maze = maze_string.each_line.map do |line|
      y += 1
      (x = line.index(START_POINT_MARKER)) && start_axes = [x, y]
      (x = line.index(END_POINT_MARKER))   && end_axes   = [x, y]
      line.unpack 'c*'
    end
    @start_point = cell *start_axes if start_axes
    @end_point   = cell *end_axes   if end_axes
  end

  def exists?(x, y)
    not at(x, y).nil?
  end

  def transform
    @maze.each_with_index.inject(Hash.new { |h, k| h[k] = []}) do |list, row, y|
      row.each_with_index do |col, x|
        cell = cell(x, y)
        list[cell] << cell.neighbors if cell.navigable?
      end
    end
  end

  def process
    return INFINITE unless @start_point && @end_point
    sources = [@start_point]
    next_sources = @start_point.neighbors
    (steps = Hash.new { |h, k| h[k] = INFINITE })[@start_point] = 0
    until next_sources.empty?
      source = next_sources.first
      next_sources.concat(
        source.neighbors.each do |neighbor|
          step = steps[neighbor] + 1
          steps[source] = step if step < steps[source]
        end
      )
      return steps[@end_point] if source == @end_point
      sources << source
      next_sources -= sources
    end
    steps[@end_point]
  end

end
