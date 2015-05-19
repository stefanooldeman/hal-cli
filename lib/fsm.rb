
class FSM

  def initialize(api)
    @api = api
    transition(api.get)
  end


  def wait(question, &block)

  end

  protected

  def transition(resource, options = {})
    @current_resource = resource
    @current_options = options
  end
end
