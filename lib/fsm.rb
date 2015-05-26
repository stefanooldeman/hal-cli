require 'ostruct'

class FSM
  class EndOfProgram < Exception; end
  class InvalidResponse < Exception; end
  HEADER = 'Wunderlist> '

  def initialize(api)
    @api = api
  end

  def begin
    transition
  end

  def add(state)
    queue << state
    queue.size
  end

  def self.puts(*args)
    output = Proc.new { |arg| IO.send(:puts, HEADER + arg.to_s) }
    if args.empty?
      output.call ''
    else
      args.each { |arg| output.call arg }
    end
  end

  protected

  def update_api
    new_api = @previous_state && @previous_state.api
    @api = new_api unless new_api.nil?
  end

  def queue; @states_queue ||= [] end

  def transition
    loop do # REPL
      begin
        FSM::puts do_eval(read)
      rescue EndOfProgram, Interrupt
        puts
        FSM::puts 'Exiting now..'
        break
      end
    end
  end

  def read
    raise EndOfProgram.new if queue.empty?

    @state = queue.shift
    update_api
    @state.setup(@api, @previous_state)
    ask_input
  end

  def do_eval(response)
    new_states = []
    begin
      result = @state.do_eval(@api, response, new_states)
      @previous_state = @state
      # update api?
    rescue InvalidResponse
      # if result is falsy, then it must be the previous run failed.
      # so we don't transition to a new state
      FSM::puts 'Error: that was invalid input, type ^C to exit'
      do_eval(ask_input) #ask again
    end

    new_states.each do |x|
      queue << x
    end
    result # for printing output
  end

  def ask_input
    IO.send(:print, HEADER) # :( otherwise it can't be mocked
    wait_for_input
  end

  def wait_for_input 
    $stdin.gets.chomp
  end

end

class State
  attr_reader :id, :data, :setup_block
  attr_accessor :api
  def initialize(id, &block)
    @id = id
    @data = OpenStruct.new
    @setup_block = block if block_given?
    @api = nil
  end

  def eval(&block)
    @eval_block = block
  end

  def setup(current_resource, previous_state)
    merge_data(previous_state) if previous_state
    if @setup_block
      @setup_block.call(current_resource, self)
    end
  end

  def do_eval(api, response, new_states = [])
    data.response = response
    @eval_block.call(api, self, new_states)
  end

  # alias methods
  def response; data.response end

  private

  def merge_data(previous_state)
    new_data = data.to_h.merge(previous_state.data.to_h)
    @data = OpenStruct.new(new_data)
  end
end
