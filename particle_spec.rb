require 'particle_explosion'
require 'matrix'

describe Particle do
  let(:subject) { Particle.create(Vector[5, 0]) }    
  it 'has heat' do
    expect(subject.heat).to eq 1
  end
  
  context 'with velocity 5,0' do
    let(:particle) { Particle.create(Vector[5, 0]) }    
    describe 'heading' do
      subject { particle.heading }
      it { is_expected.to be == 0 * Math::PI }
    end
    
    describe 'speed' do
      subject { particle.speed }
      it { is_expected.to be == 5 }
    end    
  end
  
  context 'with velocity 3,4' do
    let(:particle) { Particle.create(Vector[3, 4]) }
    describe 'speed' do
      subject { particle.speed }
      it { is_expected.to be == 5 }
    end
  end

  context 'with velocity 0, -5' do
    let(:particle) { Particle.create(Vector[0, -5]) }
    describe 'heading' do
      subject { particle.heading }
      it { is_expected.to be == -(Math::PI / 2) }
    end
  end

  describe 'succ' do
    it 'lowers the heat' do
      succ = subject.succ
      expect(succ.heat).to be < subject.heat
    end

    it 'applies gravity to velocity' do
      succ = subject.succ
      expect(succ.velocity).to be == subject.velocity + Vector[-2, 0]
    end

    it 'moves the particle according to position' do
      succ = subject.succ
      expect(succ.position).to be == subject.position + subject.velocity
    end
  end
end
