require 'spec_helper'

RSpec.describe State do

  let(:api) { double(:api) }
  let(:setup_block) { instance_double(Proc, :setup_proc) }
  let(:eval_block) { instance_double(Proc, :eval_proc) }

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
  it { is_expected.to respond_to(:eval).with(0).arguments }
  it { is_expected.to respond_to(:do_eval).with(3).arguments }

  describe '#do_eval' do
    before do
      expect(eval_block).to receive(:call).with(api, state, []) { 'world' }
    end

    it 'returns block result and self' do
      actual = subject.do_eval(api, 'hello')
      expect(actual).to eq('world')
    end

    it 'sets the response' do
      subject.do_eval(api, 'hello')
      expect(state.data.response).to eq('hello')
    end
  end

  describe '#setup' do
  end
end
