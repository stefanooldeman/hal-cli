require 'spec_helper'

RSpec.describe FSM do

  let(:api) { instance_double(Client, :api) }
  let(:api2) { instance_double(Client, :api2) }
  let(:state_one) { instance_double(State, :state_one, api: nil) }
  let(:state_two) { instance_double(State, :state_two, api: nil) }

  subject(:fsm) { described_class.new(api) }

  before do
    allow(subject).to receive(:wait_for_input) { nil }
    allow(IO).to receive(:print) # no stdout
    allow(IO).to receive(:puts) # no stdout
  end

  describe '.puts' do
    before do
      expect(IO).to receive(:puts).at_least(:once).and_call_original
    end
    it 'without args' do
      expect { FSM::puts }.to output(FSM::HEADER + "\n").to_stdout
    end

    it 'with multiple args' do
      expected = FSM::HEADER + "a\n" + FSM::HEADER + "b\n"
      expect { FSM::puts :a, 'b'}.to output(expected).to_stdout
    end
  end

  describe '#begin' do
    context 'with one state' do
      before do
        fsm.add(state_one)
      end
      after { fsm.begin }

      it 'transitions to first state' do
        expect(fsm).to receive(:wait_for_input) { 'hello' }
        expect(state_one).to receive(:setup).with(api)
        expect(state_one).to receive(:do_eval).with(api, 'hello', [])
      end

      it 're-iterates state if eval raises InvalidResponse' do
        expect(fsm).to receive(:wait_for_input) { 'hello' }
        expect(fsm).to receive(:wait_for_input).and_raise(Interrupt) # prevent recursive loop
        expect(state_one).to receive(:setup).with(api)
        expect(state_one).to receive(:do_eval).with(api, 'hello', [])
           .and_raise(FSM::InvalidResponse)
        expect(fsm).to receive(:ask_input).twice.and_call_original
      end
    end

    context 'with two states' do
      before do
        fsm.add(state_one)
        fsm.add(state_two)
        allow(state_one).to receive(:data)
        allow(state_two).to receive(:data)
      end
      after { fsm.begin }

      it 'transitions from one state to the other' do
        expect(state_one).to receive(:setup).ordered
        expect(state_one).to receive(:do_eval).ordered
        expect(state_two).to receive(:setup).ordered
        expect(state_two).to receive(:do_eval).ordered
      end

      it 'gives along the state#api to next state' do
        expect(state_one).to receive(:setup).with(api)
        expect(state_one).to receive(:api).and_return(api2)
        expect(state_one).to receive(:do_eval)
        expect(state_two).to receive(:setup).with(api2)
        expect(state_two).to receive(:do_eval)
      end

      xit 'gives along the state#data to next state' do
        expect(state_one).to receive(:setup)
        expect(state_one).to receive(:data)
          .and_return(OpenStruct.new({ response: 'y', foo: 'bar' }))
        expect(state_one).to receive(:do_eval)

        expect(state_two).to receive(:setup)
        expect(state_two).to receive(:data)
          .and_return(OpenStruct.new({ response: '1' }))
        expect(state_two).to receive(:do_eval)

        # expect(state_two.data.to_h).to eq({foo: 'bar'})
      end
    end
  end #described begin
end
