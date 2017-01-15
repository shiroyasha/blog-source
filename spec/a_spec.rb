
class User
  def to_csv
    puts "here"
  end

  def from_csv
    puts "a2"
  end
end

shared_examples "a CSV serializable object" do
  it { is_expected.to respond_to(:to_csv) }
  it { is_expected.to respond_to(:from_csv) }
end

describe User do
  it_behaves_like "a CSV serializable object"
end
