require 'spec_helper'
require 'server_bridge'

describe ServerBridge do
  context "#connect" do
    let(:connection1) { double('connection1') }
    let(:connection2) { double('connection1') }
    let(:connection3) { double('connection1') }
    let(:connections) {
      {
        '456' => connection2,
        '789' => connection3
      }
    }
    let(:message) { "hello_mum" }
    let(:socket) { double("socket", hello_mum: "xxxx") }

    before :each do
      expect(Connection).to receive(:new)
        .with(socket, '123')
        .and_return(connection1)

      expect(connection1).to receive(:socket).once.and_return(socket)
      expect(socket).to receive(:send).once.and_return(true)

      subject.connections = connections
    end

    it { expect(subject.connect(socket, '123')).to be_truthy }
  end


  context "#broadcast" do
    let(:connection1) { double('connection1') }
    let(:connection2) { double('connection1') }
    let(:connection3) { double('connection1') }
    let(:connections) {
      {
        '123' => connection1,
        '456' => connection2,
        '789' => connection3
      }
    }
    let(:message) { "hello_mum" }
    let(:socket) { double("socket", hello_mum: "xxxx") }

    before :each do
      expect(connection1).to receive(:socket).once.and_return(socket)
      expect(connection2).to receive(:socket).once.and_return(socket)
      expect(connection3).to receive(:socket).once.and_return(socket)
      expect(socket).to receive(:hello_mum).exactly(3).times

      subject.connections = connections
    end

    it { expect(subject.broadcast(message)).to be_truthy }
  end

  context "#disconnect" do
    let(:connection1) { double('connection1') }
    let(:connection2) { double('connection1') }
    let(:connection3) { double('connection1') }
    let(:connections) {
      {
        '123' => connection1,
        '456' => connection2,
        '789' => connection3
      }
    }

    before :each do
      expect(connections).to receive(:delete)
        .once
        .with('123')
        .and_return(true)

      subject.connections = connections
    end

    it { expect(subject.disconnect('socket', '123')).to be_truthy }
  end

  context "#send" do
    let(:payload) { "{\"user_id\": 22,\"setVol\": 40}" }
    let(:socket) { "socket" }

    before :each do
      expect(MessageDispatcher).to receive(:send!)
        .with(payload)
        .and_return(true)
    end

    it { expect(subject.send(payload, socket, 99)).to be_truthy }
  end
end
