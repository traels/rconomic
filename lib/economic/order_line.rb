require 'economic/entity'
require 'economic/order'

module Economic

  # Represents a order line.
  #
  # API documentation: http://www.e-conomic.com/apidocs/Documentation/T_Economic_Api_IOrderLine.html
  #
  # See Economic::Order for usage example
  class OrderLine < Entity
    has_properties :number,
      :order_handle,
      :description,
      :delivery_date,
      :unit_handle,
      :product_handle,
      :quantity,
      :unit_net_price,
      :discount_as_percent,
      :unit_cost_price,
      :total_net_amount,
      :total_margin,
      :margin_as_percent

    defaults(
      :order_handle => nil,
      :description => nil,
      :delivery_date => nil,
      :unit_handle => nil,
      :product_handle => nil,
      :quantity => nil,
      :unit_net_price => nil,
      :discount_as_percent => 0.0,
      :unit_cost_price => 0.0,
      :total_net_amount => nil,
      :total_margin => 0.0,
      :margin_as_percent => 0.0
    )

    def handle
      @handle || Handle.build(:number => number)
    end

    def order
      return nil unless order_handle
      @order ||= session.orders.find(order_handle)
    end

    def order=(order)
      @order = order
      self.order_handle = order.handle
    end

    def product=(product)
      self.product_handle = product.handle
      self.unit_handle = product.unit_handle
      self.unit_net_price = product.sales_price
      self.unit_cost_price = product.cost_price
      self.description = product.name
    end

    protected

    def fields
      to_hash = Proc.new { |h| h.to_hash }
      [
        ["Number", :number, Proc.new { 0 }, :required], # Doesn't seem to be used
        ["OrderHandle", :order_handle, to_hash],
        ["Description", :description],
        ["DeliveryDate", :delivery_date, nil, :required],
        ["UnitHandle", :unit_handle, to_hash],
        ["ProductHandle", :product_handle, to_hash],
        ["Quantity", :quantity, nil, :required],
        ["UnitNetPrice", :unit_net_price, nil, :required],
        ["DiscountAsPercent", :discount_as_percent],
        ["UnitCostPrice", :unit_cost_price],
        ["TotalNetAmount", :total_net_amount, nil, :required],
        ["TotalMargin", :total_margin],
        ["MarginAsPercent", :margin_as_percent]
      ]
    end
  end
end
