require "./spec_helper"

describe Board do
  it "initialize" do
    b = Board.new
    b.should eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    b = Board.new Array.new(16) { |i| i }
    b.should eq [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]
  end

  it "transpose!" do
    b = Board.new Array.new(16) { |i| i }
    b.transpose!
    b.should eq [0, 4, 8, 12, 1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15]
  end

  it "rotate_left!" do
    b = Board.new Array.new(16) { |i| i }
    b.rotate_left!
    b.should eq [3, 7, 11, 15, 2, 6, 10, 14, 1, 5, 9, 13, 0, 4, 8, 12]
  end

  it "rotate_right!" do
    b = Board.new Array.new(16) { |i| i }
    b.rotate_right!
    b.should eq [12, 8, 4, 0, 13, 9, 5, 1, 14, 10, 6, 2, 15, 11, 7, 3]
  end

  it "move!" do
    b = Board.new [1, 1, 0, 3, 0, 0, 0, 0, 9, 0, 5, 0, 7, 0, 0, 0]
    b.move!(:left)
    b.should eq [2, 3, 0, 0, 0, 0, 0, 0, 9, 0, 5, 0, 7, 0, 0, 0]
    b.move!(:right)
    b.should eq [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 9, 5, 0, 0, 0, 7]
    b.move!(:down)
    b.should eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 9, 7]
    b.move!(:up)
    b.should eq [0, 0, 9, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    b.move!(:left)
    b.should eq [10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end

  it "add_random_tile!" do
    b = Board.new
    b.add_random_tile!
    b.board.count(&.== 0).should eq 15
    b.board.count { |e| e == 1 || e == 2 } .should eq 1
    b.add_random_tile!
    b.board.count(&.== 0).should eq 14
    b.board.count { |e| e == 1 || e == 2 } .should eq 2
  end
end