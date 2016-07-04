require 'rails_helper'

describe JbCall::Handler do
  let(:command) { 'vote' }
  let(:user) { double('user', id: 99) }

  context "voting" do
    let(:response) { "ok" }

    context "when making a valid vote" do
      context "when making an up vote" do
        let(:arguments) { { state: 1, filename: 'track1' }.with_indifferent_access }

        before :each do
          expect(VoteHandler).to receive(:vote!)
            .once
            .with(arguments[:filename], arguments[:state], user.id)
            .and_return(response)
         end

        it "should provide a response" do
          expect(described_class.execute!(command, arguments, user.id)).to eql(response)
        end
      end

      context "when making a down vote" do
        let(:arguments) { { state: 0, filename: 'track1' }.with_indifferent_access }

        before :each do
          expect(VoteHandler).to receive(:vote!)
            .once
            .with(arguments[:filename], arguments[:state], user.id)
            .and_return(response)
         end

        it "should provide a response" do
          expect(described_class.execute!(command, arguments, user.id)).to eql(response)
        end
      end
    end

    context "when making an invalid vote" do
      it "should return nil" do
        expect(described_class.execute!(command, "", user.id)).to be_nil
      end
    end
  end
end