class NpuzzleSolver
  def self.resolve
    puzzle = '0 2 8,7 4 1,6 3 5' #Unsolveable, undetected
    # puzzle = '0 1 2,5 4 3,6 7 8' #Solveable in 2 moves
    # puzzle = '1 0 2,3 4 5,8 7 6' #Solveable in 25 moves
    # puzzle = '1 2 5,4 3 0,6 7 8' #Solveable in 15 moves
    # puzzle = '1 2 5,4 3 0,6 8 7' #Unsolveable, detected
    # puzzle = '1 2 5,3 4 0,6 8 7' #Solveable In 19 Moves
    # puzzle = '1 0 2 3,4 5 6 7,8 9 10 11,15 14 13 12' #Solveable in 25 moves
    # puzzle = '1 2 3 0,4 5 6 7,8 9 10 11,15 14 13 12' #Solveable in 27 moves
    # puzzle = '1 2 3 0,4 5 7 6,8 10 9 11,12 14 13 15' #Takes too long
    # puzzle = '4 5 6 0,1 2 3 7,8 9 10 11,15 14 13 12' #5 Inversions Detected
    # puzzle = '1 2 3 0,7 5 6 4,8 9 10 11,15 14 13 12' #Takes too long
    # puzzle = '1 2 3 0,7 5 6 4,8 9 11 12,15 14 13 10' #Not Solveable Detected, 7 Inversions
    # puzzle = '1 2 3 0,7 5 4 8,6 9 12 11,15 14 13 10' #Takes too long
    # puzzle = '1 0 2 3,4 5 6 7,14 9 10 11,15 8 13 12' # Not Solved
    # puzzle = '1 0 2 4,3 5 6 7,8 9 10 11,15 14 13 12' #Not Solveable, Detected 5 Inversions
    # puzzle = '1 0 2 4,3 5 6 7,8 9 10 15,11 14 13 12' #Not Solveable, Detected 5 Inversions
    # puzzle = '12 0 2 4,3 5 6 7,8 9 10 15,11 14 13 1'  #Not Solveable, Detected 5 Inversions
    # puzzle = '12 2 0 4,3 5 6 7,8 9 10 15,11 14 1 13'  #Not Solveable, Detected 5 Inversions
    # puzzle = '1 2 5 9,3 4 0 10,6 8 7 11,15 14 13 12' # Detected as unsolveable with 7 inversions
    # puzzle = '0 2 1 3,4 5 6 7,8 11 9 10,15 14 13 12' # Not Solved, not detected as unsolveable
    # puzzle = '1 0 2 3,4 5 6 7,8 9 10 11,12 13 14 15' #Not Solved, Not Detected
    # puzzle = '1 0 2 3,4 5 6 7,8 9 10 11,12 14 13 15' # Not Solved, Not Detected
    # puzzle = '1 0 2 3 16,4 5 6 7 17,8 9 10 11 18,12 14 13 15 19,24 23 22 21 20' #Unsolveable, 13 Inversions
    # puzzle = '1 0 2 3 4,9 8 7 6 5,10 11 12 13 14,19 18 17 16 15,20 21 22 23 24' # Solveable
    # puzzle = '1 0 2 3 4,5 6 7 8 9,10 11 12 13 14,15 16 17 18 19,20 21 22 23 24' # Solveable

    complete_puzzle = '0 1 2,3 4 5,6 7 8'
    # complete_puzzle = '0 1 2 3,4 5 6 7,8 9 10 11,12 13 14 15'
    # complete_puzzle = '0 1 2 3 4,5 6 7 8 9,10 11 12 13 14,15 16 17 18 19,20 21 22 23 24'
    chosen_heuristic = 'manhattan'

    end_state = Node.new(complete_puzzle, 0, nil, nil, end_node: true, heuristic: chosen_heuristic)
    start = Node.new(puzzle, 0, nil, end_state, start_node: true, heuristic: chosen_heuristic)
    solution = {start: start, 
                end: end_state, 
                open_set: Hash.new(Array.new).merge({0 => [start]}),
                closed_set: [],
                solution: [],
                representations: {}
              }


    
    # blank_pos = end_state.state.select{|v| v.include?(0)}.first.find_index(0)
    # check = puzzle.clone.delete!(' ,0')
    # index = 0
    # inversions = 0
    # while check[index + 1]
    #   inversions += 1 if check[index] > check[index + 1]
    #   index += 1
    # end
    # if (inversions % 2 == 1 && end_state.state.size % 2 == 1) || (end_state.state.size % 2 == 0 && (end_state.state.size - blank_pos) % 2 != inversions % 2) 
    #   solution[:solution] = ["- Puzzle Cannot Be Solved! - #{inversions} #{'inversion'.pluralize(inversions)}"]
    #   return solution
    # end

    solution_found = false
    iteration = 1
    start_time = Time.now

    lock = Mutex.new

    # threads = Array.new(2) do
    #   Thread.new do
          while !solution_found && !solution[:open_set].map{|k,v| v.size}.sum.zero? && iteration < 500_000 && (Time.now - start_time) < 3
            index = 0
            lock.synchronize{ index += 1 } while solution[:open_set][index].empty?
            current = lock.synchronize{ solution[:open_set][index].shift }
            # solution[:open_set].delete(index) if solution[:open_set][index].empty?

            new_nodes = current.explore
            unless new_nodes.empty?
              new_nodes.map do |node|
                if Node.matching_state?(node.state, end_state.state)
                  while node
                    lock.synchronize{ solution[:solution] << node.state }
                    node = node.parent
                  end
                  solution_found = true
                end
              end
              new_nodes.each do |node|
                if !solution[:representations].has_key?(node.state.flatten.to_s)
                  # puts "Adding Node To Open Set"
                  lock.synchronize{ solution[:open_set][node.weight] = [] } unless solution[:open_set].has_key?(node.weight)
                  lock.synchronize{ solution[:open_set][node.weight] << node }
                  lock.synchronize{ solution[:representations][node.state.flatten.to_s] = true }
                end
              end
            end
            lock.synchronize{ solution[:closed_set] << current}
          
          # puts "Open Set: #{solution[:open_set].map{|k,v| v.size}.sum}, Iteration: #{iteration += 1}, State: #{current.state.flatten.to_s}, Weight: #{current.weight}, Distance: #{current.distance}, Heuristic: #{current.heuristic}"
        end
      # end
    # end

    # threads.each(&:join)

    # timer = 2
    # while !timer.zero? && !solution_found
    #   sleep 2
    #   if solution[:open_set].map{|k,v| v.size}.sum > 0
    #     timer -= 1 
    #   else
    #     timer = 2
    #   end
    # end

    # thread.join
    # ap solution[:representations]

    if solution[:open_set].map{|k,v| v.size}.sum.zero? && solution[:solution].empty?
      solution[:solution] = ['- Puzzle Cannot Be Solved! Open Set Has Been Emptied']
    end

    solution[:solution] << 'No Solution Found, Took Longer Than 3 Seconds' if solution[:solution].empty?
    solution
  end
end

class Node
  def initialize(state, distance, parent, end_state, options = {heuristic: 'hamming'})
    @options = options
    @parent = parent
    @end_state = end_state
    
    if state.class == String
      @state = state.split(',').map{|v| v.split(' ').map{|v| v.to_i}}
    elsif state.class == Array
      @state = state
    end

    @distance = distance
    @heuristic = heuristic_weight(@options[:heuristic])
    @weight = distance + @heuristic
  end

  def explore
    return [] if @distance >= 100 #Come back to this later -TODO
    new_nodes = []
    x = 0
    y = 0

    while x < @state.size
      if @state[x][y] == 0
        [{x: -1, y: 0}, {x: 1, y: 0}, {x: 0, y: -1}, {x: 0, y: 1}].each do |move|
          new_state = @state.map{|v| v.clone}
          next if new_state[x + move[:x]].nil? || new_state[x + move[:x]][y + move[:y]] == nil || x + move[:x] < 0 || x + move[:x] > @state.size || y + move[:y] < 0 || y + move[:y] > @state.size
          temp = new_state[x + move[:x]][y + move[:y]]
          new_state[x + move[:x]][y + move[:y]] = new_state[x][y]
          new_state[x][y] = temp
          new_nodes << Node.new(new_state, @distance + 1, self, @end_state, heuristic: options[:heuristic]) unless x < 0 && x > @state.size && y < 0 && y > @state.size && !matching_state?(new_state, parent.state)
        end
      end
      y += 1
      if y > @state.size
        y = 0
        x += 1
      end
    end

    new_nodes
  end

  def heuristic_weight(selection)
    return 0 if @state.nil? || @end_state.nil?
    result = 0
    x = 0 
    y = 0

    while x < @state.size
      result += 1 unless @state[x][y] == @end_state.state[x][y] if selection == 'hamming'
      if selection == 'manhattan'
        tempx = 0
        tempy = 0
        loop do
          if @end_state.state[tempx].include?(@state[x][y])
            tempy = @end_state.state[tempx].find_index(@state[x][y])
            break 
          end
          tempx += 1
        end
        cost = (x - tempx).abs + (y - tempy).abs
        result += cost unless @state[x][y] == @end_state.state[x][y]
      end
      
      y += 1
      if y > @state.size - 1
        y = 0
        x += 1
      end
    end

    return result
  end

  def self.matching_state?(state_one, state_two)
    return false if state_one.nil? || state_two.nil?
    x = 0
    y = 0
    while x < state_one.size
      return false unless state_one[x][y] == state_two[x][y]
      y += 1
      if y > state_one.size
        y = 0
        x += 1
      end
    end
    return true
  end

  attr_reader :options, :weight, :state, :distance, :heuristic, :weight, :parent
end