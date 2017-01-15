
class C
  def initialize
    @c = []
  end

  def add(el)
    @c << el
    self
  end

  def remove(el)
   @c = @c.reject { |e| e == el }
   self
  end

  def include?(el)
    @c.include?(el)
  end
end


shared_examples "a collection" do
  it { is_expected.to respond_to(:add).with(1).argument }
  it { is_expected.to respond_to(:remove).with(1).argument }
  it { is_expected.to respond_to(:include?).with(1).argument }

  before do
    @collection = described_class.new
  end

  describe ".add" do
    it "adds an element into the collection" do
      @collection.add(12)

      expect(@collection).to include(12)
    end

    it "returns the collection" do
      expect(@collection.add(12)).to eq(@collection)
    end
  end

  describe ".remove" do
    context "the element is not present" do
      it "doesn't raise an exception" do
        expect { @collection.remove(12) }.to_not raise_exception
      end
    end

    it "removes the element from the collection" do
      @collection.add(12)
      expect(@collection).to include(12)

      @collection.remove(12)
      expect(@collection).to_not include(12)
    end

    it "returns the collection" do
      expect(@collection.remove(12)).to eq(@collection)
    end
  end
end


describe C do
  it_behaves_like "a collection"
end
