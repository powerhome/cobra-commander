# frozen_string_literal: true

require "spec_helper"

RSpec.describe Cbra::Affected do
  before(:all) do
    @root = AppHelper.root
    @tree = AppHelper.tree
  end

  it "successfully instantiates" do
    expect(described_class.new(@tree, [], @root)).to be_truthy
  end

  context "with no changes" do
    let(:no_changes) do
      described_class.new(@tree, [], @root)
    end

    it "reports no directly affected components" do
      expect(no_changes.directly).to eq Set.new
    end

    it "reports no transitiely affected components" do
      expect(no_changes.transitively).to eq Set.new
    end

    it "reports no testing needs" do
      expect(no_changes.needs_testing).to eq Set.new
    end
  end

  context "with change to top level dependency" do
    let(:with_change_to_a) do
      described_class.new(@tree, ["#{@root}/components/a/Gemfile"], @root)
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.directly).to eq Set.new(
        [
          {
            name: "a",
            path: "#{@root}/components/a",
          },
        ]
      )
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_a.transitively).to eq Set.new
    end

    it "correctly reports testing needs" do
      expect(with_change_to_a.needs_testing).to eq Set.new(["#{@root}/components/a/test.sh"])
    end
  end

  context "with change to lowest level dependency" do
    let(:with_change_to_b) do
      described_class.new(@tree, ["#{@root}/components/b/Gemfile"], @root)
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_b.directly).to eq Set.new(
        [
          {
            name: "b",
            path: "#{@root}/components/b",
          },
        ]
      )
    end

    it "correctly reports directly affected components" do
      expect(with_change_to_b.transitively).to eq Set.new(
        [
          {
            name: "a",
            path: "#{@root}/components/a",
          },
          {
            name: "c",
            path: "#{@root}/components/c",
          },
          {
            name: "d",
            path: "#{@root}/components/d",
          },
        ]
      )
    end

    it "correctly reports testing needs" do
      expect(with_change_to_b.needs_testing).to include("#{@root}/components/a/test.sh")
      expect(with_change_to_b.needs_testing).to include("#{@root}/components/b/test.sh")
      expect(with_change_to_b.needs_testing).to include("#{@root}/components/c/test.sh")
      expect(with_change_to_b.needs_testing).to include("#{@root}/components/d/test.sh")
    end
  end
end
