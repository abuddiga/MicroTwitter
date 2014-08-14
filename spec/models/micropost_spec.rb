require 'rails_helper'

describe Micropost do

	let(:user) { FactoryGirl.create(:user) }

	before do
		@micropost = user.microposts.build(content: "New Tweet")
	end

	subject { @micropost }

	it { should respond_to(:content) }
	it { should respond_to(:user_id) }
	it { should respond_to(:user) }

	it { should be_valid }

	describe "when there is no user id" do
		before { @micropost.user_id = nil }
		it { should_not be_valid }
	end

	describe "with blank content" do
		before { @micropost.content = " " }
		it { should_not be_valid }
	end

	describe "micropost is too long" do
		before { @micropost.content = "a" * 141 }
		it { should_not be_valid }
	end
end