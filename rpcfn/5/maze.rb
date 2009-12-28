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

  def navigable?(cell)
    @maze[cell.x][cell.y] != C_wall
  end

  def exists?(x, y)
    !(x < 0 || y < 0) and (row = @maze[y]) and row[x]
  end

  def process
    to_graph.shortest_path(@start_point, @end_point)
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
      puts "cells: #{cells}"
      puts "visited: #{visited}"
      cells -= visited
      puts "then: #{cells}"
      sleep 5
    end
    steps[@end_point]
  end

  def to_graph
    Graph.new(self) do |a, b|
    end
    @maze.each_with_index.inject(Graph.new) do |graph, row, row_ind|
      row.each_with_index do |col, col_ind|
        cell = cell(row_ind, col_ind)
        graph[cell] << cell.neighbors.select { |c| navigable? c } if navigable?(cell)
      end
    end
  end

end

# jacacency list graph
class Graph
  def initialize(matrix)
    matrix.each
  end

  def [](vertex)
  end

  def shortest_path(from, to)
  end
end
