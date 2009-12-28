class Maze
  START_POINT_MARKER = 'A'.freeze
  END_POINT_MARKER   = 'B'.freeze
  WALL               = '#'.unpack('c').first.freeze
  INFINITE           = (1.0 / 0.0).freeze

  class Cell
    attr_reader :x, :y, :maze

    def initialize(maze, x, y)
      @maze = maze
      @x, @y = x, y
    end

    def neighbors
      @neighbors ||= begin
        neighbors = []
        (up    = maze.cell(self.x, self.y - 1)) && neighbors << up
        (left  = maze.cell(self.x - 1, self.y)) && neighbors << left
        (below = maze.cell(self.x, self.y + 1)) && neighbors << below
        (right = maze.cell(self.x + 1, self.y)) && neighbors << right
        neighbors
      end
    end

    def eql?(other)
      other.is_a?(Cell) &&
      x == other.x &&
      y == other.y
    end
  end

  def initialize(maze_string)
    @cells = {}
    parse maze_string
  end

  def solvable?
    steps == INFINITE
  end

  def steps
    @steps ||= process
  end

  def cell(x, y)
    @cells.has_key?([x, y]) ? @cells[[x, y]] :
      @cells[[x, y]] = exists?(x, y) ? Cell.new(self, x, y) : nil
  end

  private
  def parse(maze_string)
    row = -1
    start_axes = end_axes = nil
    @maze = maze_string.each_line.map do |line|
      row += 1
      (col = line.index(START_POINT_MARKER)) && start_axes = [col, row]
      (col = line.index(END_POINT_MARKER))   && end_axes   = [col, row]
      line.unpack 'c*'
    end
    @start_point = cell *start_axes
    @end_point   = cell *end_axes
  end

  def navigable?(cell)
    @maze[cell.x][cell.y] != C_wall
  end

  def exists?(x, y)
    (row = @maze[x]) and row[y]
  end

  def transform_to_adjacency_list
    @maze.each_with_index.inject(Hash.new { |h, k| h[k] = [] }) do |list, row, row_ind|
      row.each_with_index do |col, col_ind|
        cell = cell(row_ind, col_ind)
        list[cell] << cell.neighbors.select { |c| navigable? c } if navigable?(cell)
      end
    end
  end

  def process
    (steps = Hash.new { |h, k| h[k] = INFINITE })[@start_point] = 0
    cells = [@start_point]
    visited = []
    puts "From: (#{@start_point.x}, #{@start_point.y}) to (#{@end_point.x}, #{@end_point.y})."
    while !cells.empty?
      visited.concat cells
      cells.map! do |cell|
        STDOUT.print("Visit[#{cell.x}, #{cell.y}]: ");
        step = steps[cell] + 1
        n = cell.neighbors.each do |neighbor|
          STDOUT.print "(#{neighbor.x}, #{neighbor.y}), "
          steps[neighbor] = step if step < steps[neighbor]
        end
        STDOUT.print "\n"
        STDOUT.flush
        n
      end.flatten!
      cells -= visited
      sleep 5
    end
    steps[@end_point]
  end

end
