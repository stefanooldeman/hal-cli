class FSM
  attr_accessor :data 

  def initialize(api)
    @api = api
    @result = api
    @register = {}
    @states_q = []
  end

  def begin
    transition
  end

  def next
  end

  def add(state)
    @register[state.id] = state
    @states_q << state
  end

  protected

  def transition
    loop do # REPL
      puts do_eval(*read)
    end
  end

  def read
    if @result
      @_read_state = @states_q.shift
      @_read_state.setup(@result || api, @result)
    else
      # if result is falsy, then it must be the previous run failed.
      # so we don't transition to a new state
      puts 'Error: that was invalid input, type ^C to exit'
      puts
    end
    [@_read_state, gets.chomp]
  end

  def do_eval(state, response)
    result = state.do_eval(response)
    @result = result[:data]
    result = result[:message]
  end
end

class State
  attr_reader :id
  def initialize(id, &eval_block)
    @id = id
    @pre_read = eval_block if block_given?
    @data = {}
  end

  def eval(&block)
    @eval_block = block
  end

  def setup(current_resource_api, state)
    if @pre_read
      # state is result returned in eval[:data], @data is new to be used for storage
      @pre_read.call(current_resource_api, state, @data)
    end
  end

  def do_eval(response)
    @eval_block.call(response, @data)
  end
end
