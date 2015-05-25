require 'spec_helper'

RSpec.describe State do

  let(:api) { double(:api) }
  let(:setup_block) { instance_double(Proc, :setup_block) }
  let(:eval_block) { instance_double(Proc, :eval_block) }
  let(:next_state) do
    State.new(api).tap do |a|
      a.instance_variable_set(:@eval_block, eval_block)
    end
  end
  let(:state_double) { instance_double(State, :a_state, data: OpenStruct.new(a: 'bar')) }

  subject(:state) do
    described_class.new(:a).tap do |a|
      a.instance_variable_set(:@setup_block, setup_block)
      a.instance_variable_set(:@eval_block, eval_block)
    end
  end

  it { is_expected.to respond_to(:id) }
  it { is_expected.to respond_to(:data) }
  it { is_expected.to respond_to(:api) }
  it { is_expected.to respond_to(:api=) }
  it { is_expected.to respond_to(:setup).with(2).arguments }
  it { is_expected.to respond_to(:eval).with(0).arguments }
  it { is_expected.to respond_to(:do_eval).with(3).arguments }

  describe '#do_eval' do
    before do
      expect(eval_block).to receive(:call).with(api, state, []) { 'world' }
    end

    it 'returns block result and self' do
      actual = state.do_eval(api, 'hello')
      expect(actual).to eq('world')
    end

    it 'sets the response' do
      state.do_eval(api, 'hello')
      expect(state.data.response).to eq('hello')
    end
  end

  describe '#setup' do
    context 'with a block' do
      it 'execute the setup call' do
        expect(setup_block).to receive(:call).with(api, state)
        expect(state).not_to receive(:merge_data)
        state.setup(api, nil)
      end

      it 'merges previous state#data when given' do
        expect(setup_block).to receive(:call).with(api, state)
        expect(state).to receive(:merge_data)
        state.setup(api, state_double)
      end
    end

    context 'without a block' do
      before { state.remove_instance_variable(:@setup_block) }

      it 'skips the setup call' do
        expect(setup_block).not_to receive(:call)
        expect(state).not_to receive(:merge_data)
        state.setup(api, nil)
      end

      it 'merges previous state#data when given' do
        expect(setup_block).not_to receive(:call)
        expect(state).to receive(:merge_data)
        state.setup(api, state_double)
      end
    end

    context 'with previous state' do
      it 'merges data from previous_state' do
        expect(state).to receive(:data)
          .and_return(OpenStruct.new({ response: 'y', number: 4 }))
        next_state.setup(api, state)
        expect(next_state.data.class).to be(OpenStruct)
        expect(next_state.data.to_h).to eq({response: 'y', number: 4})
      end
    end
  end # describe setup
end
