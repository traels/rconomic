require 'economic/entity'

module Economic
  class Order < Entity
    has_properties :id,
      :number,
      :debtor_handle,
      :debtor_name,
      :debtor_address,
      :debtor_postal_code,
      :debtor_city,
      :debtor_country,
      :debtor_ean,
      :public_entry_number,
      :attention_handle,
      :date,
      :term_of_payment_handle,
      :currency_handle,
      :exchange_rate,
      :is_vat_included,
      :layout_handle,
      :project_handle,
      :delivery_date,
      :net_amount,
      :vat_amount,
      :due_date,
      :gross_amount,
      :margin,
      :margin_as_percent,
      :attention_handle,
      :your_reference_handle,
      :our_reference_handle,
      :our_reference2_handle,
      :heading,
      :text_line1,
      :is_sent,
      :is_archived,
      :text_line2

    defaults(
      :id => 0,
      :is_sent => false,
      :is_archived => false,
      :date => Time.now,
      :term_of_payment_handle => nil,
      :due_date => nil,
      :currency_handle => nil,
      :exchange_rate => 100, # Why am _I_ inputting this?
      :is_vat_included => nil,
      :layout_handle => nil,
      :delivery_date => nil,
      :heading => nil,
      :net_amount => 0.0,
      :vat_amount => 0.0,
      :gross_amount => 0.0,
      :margin => 0.0,
      :margin_as_percent => 0.0 # Why do I have to input both Margin and MarginAsPercent? Shouldn't powerful Windows machines running ASP.NET be able to compute this?
    )


    def initialize(properties = {})
      super
    end

    def attention
      return nil if attention_handle.nil?
      @attention ||= session.contacts.find(attention_handle)
    end

    def attention=(contact)
      self.attention_handle = contact.handle
      @attention = contact
    end

    def attention_handle=(handle)
      @attention = nil unless handle == @attention_handle
      @attention_handle = handle
    end

    def debtor
      return nil if debtor_handle.nil?
      @debtor ||= session.debtors.find(debtor_handle)
    end

    def debtor=(debtor)
      self.debtor_handle = debtor.handle
      @debtor = debtor
    end

    def debtor_handle=(handle)
      @debtor = nil unless handle == @debtor_handle
      @debtor_handle = handle
    end

    def lines
      @lines ||= OrderLineProxy.new(self)
    end

    # Returns the PDF version of Invoice as a String.
    #
    # To get it as a file you can do:
    #
    #   File.open("invoice.pdf", 'wb') do |file|
    #     file << invoice.pdf
    #   end
    def pdf
      response = request(:get_pdf, {
                           "orderHandle" => handle.to_hash
      })

      Base64.decode64(response)
    end

    protected

    def fields
      date_formatter = Proc.new { |date| date.respond_to?(:iso8601) ? date.iso8601 : nil }
      to_hash = Proc.new { |handle| handle.to_hash }
      [
        ["Handle", :handle, to_hash],
        ["Id", :id, nil, :required],
        ["DebtorHandle", :debtor, Proc.new { |d| d.handle.to_hash }],
        ["Number", :number],
        ["DebtorName", :debtor_name],
        ["DebtorAddress", :debtor_address],
        ["DebtorPostalCode", :debtor_postal_code],
        ["DebtorCity", :debtor_city],
        ["DebtorCountry", :debtor_country],
        ['DebtorEan', :debtor_ean],
        ['PublicEntryNumber', :public_entry_number],
        ["AttentionHandle", :attention_handle, to_hash],
        ["Date", :date, date_formatter],
        ["TermOfPaymentHandle", :term_of_payment_handle, to_hash],
        ["DueDate", :due_date, date_formatter, :required],
        ["CurrencyHandle", :currency_handle, to_hash],
        ["ExchangeRate", :exchange_rate],
        ["IsVatIncluded", :is_vat_included, nil, :required],
        ["LayoutHandle", :layout_handle, to_hash],
        ["DeliveryDate", :delivery_date, date_formatter, :required],
        ["Heading", :heading],
        ['TextLine1', :text_line1],
        ['TextLine2', :text_line2],
        ["AttentionHandle", :attention_handle],
        ["IsArchived", :is_archived, Proc.new { |v| v || "false" }, :required],
        ["IsSent", :is_sent, Proc.new { |v| v || "false" }, :required],
        ["NetAmount", :net_amount, nil, :required],
        ["VatAmount", :vat_amount, nil, :required],
        ["GrossAmount", :gross_amount, nil, :required],
        ["Margin", :margin, nil, :required],
        ["MarginAsPercent", :margin_as_percent, nil, :required]
      ]
    end
  end
end
