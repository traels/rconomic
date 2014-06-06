require './spec/spec_helper'

describe Economic::OrderLine do
  let(:session) { make_session }
  subject { (l = Economic::OrderLine.new).tap { l.session = session } }

  it "inherits from Economic::Entity" do
    expect(Economic::OrderLine.ancestors).to include(Economic::Entity)
  end

  describe "equality" do
#    it "should not be equal when both are newly created" do # WHY NOT?
#      line1 = Economic::OrderLine.new({})
#      line2 = Economic::OrderLine.new({})
#
#      expect(line1).not_to eq(line2)
#    end

    it "should not be equal when numbers are different" do
      line1 = Economic::OrderLine.new({:number => 1})
      line2 = Economic::OrderLine.new({:number => 2})

      expect(line1).not_to eq(line2)
    end
  end

  describe "#order=" do
    it "changes the order_handle" do
      order = Economic::Order.new()

      subject.order = order

      expect(subject.order).to eq(order)
      expect(subject.order_handle).to eq(order.handle)
    end
  end

  describe ".proxy" do
    it "should return a OrderLineProxy" do
      expect(subject.proxy).to be_instance_of(Economic::OrderLineProxy)
    end

    it "should return a proxy owned by session" do
      expect(subject.proxy.session).to eq(session)
    end
  end

  describe "#save" do
    context "when successful" do
      it "builds and sends data to API" do
        mock_request(
          "OrderLine_CreateFromData", {
            "data" => {
              "Handle" => {"Id"=>0, "Number"=>0},
              "Id" => 0,
              "Number" => 0,
              "DeliveryDate" => nil,
              "Quantity" => nil,
              "UnitNetPrice" => nil,
              "DiscountAsPercent" => 0.0,
              "UnitCostPrice" => 0.0,
              "TotalNetAmount" => nil,
              "TotalMargin" => 0.0,
              "MarginAsPercent" => 0.0
            }
          },
          :success
        )
        subject.save
      end
    end
  end
end
