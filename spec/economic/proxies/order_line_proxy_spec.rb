require './spec/spec_helper'

describe Economic::OrderLineProxy do
  let(:session) { make_session }
  let(:order) { Economic::Order.new(:session => session, :number => 512) }
  subject { Economic::OrderLineProxy.new(order) }

  describe "new" do
    it "stores owner" do
      expect(subject.owner).to eq(order)
    end

    it "stores session" do
      expect(subject.session).to eq(order.session)
    end
  end

  describe ".append" do
    it "ignores duplicated lines" do
      line = Economic::OrderLine.new
      subject.append(line)
      subject.append(line)
      expect(subject.size).to eq(1)
    end
  end

  describe ".build" do
    it "instantiates a new OrderLine" do
      expect(subject.build).to be_instance_of(Economic::OrderLine)
    end

    it "assigns the session to the OrderLine" do
      expect(subject.build.session).to eq(session)
    end

    it "should not build a partial OrderLine" do
      expect(subject.build).to_not be_partial
    end

    it "adds the built line to proxy items" do
      line = subject.build(:number => 5)
      expect(subject.first).to eq(line)
    end

    context "when owner is a Order" do
      subject { order.lines }

      it "should use the Debtors session" do
        expect(subject.build.session).to eq(order.session)
      end

      it "should initialize with values from Order" do
        order_line = subject.build
        expect(order_line.order_handle).to eq(order.handle)
      end
    end
  end

  describe ".find" do
    it "gets order_line data from API" do
      mock_request('OrderLine_GetData', {'entityHandle' => {'Number' => 42}}, :success)
      subject.find(42)
    end

    it "returns OrderLine object" do
      stub_request('OrderLine_GetData', nil, :success)
      expect(subject.find(42)).to be_instance_of(Economic::OrderLine)
    end
  end

  describe "enumerable" do
    it "can be empty" do
      expect(subject).to be_empty
    end

    it "can be appended to" do
      line = Economic::OrderLine.new(:number => 5)
      subject << line
      expect(subject.last).to eq(line)
    end

    it "can be iterated over" do
      line = Economic::OrderLine.new
      subject << line
      expect(subject.all? { |l| l.is_a?(Economic::OrderLine) }).to be_true
    end
  end
end
