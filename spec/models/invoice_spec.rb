require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status}
    it { should define_enum_for(:status).with_values("In Progress" => 0, "Completed" => 1, "Cancelled" => 2)}
  end

  describe "relationships" do
    it {should belong_to :customer}
    it {should have_many :invoice_items}
    it {should have_many :transactions}
    it {should have_many(:items).through(:invoice_items)}
  end

  describe "class methods" do
    before do
      @customer_1 = create(:customer)
  
      @merchant_1 = create(:merchant)
      @items = create_list(:item, 5, merchant: @merchant_1)
  
      @invoice_1 = create(:invoice, customer: @customer_1, created_at: "2015-12-09")
      @invoice_2 = create(:invoice, customer: @customer_1, created_at: "2013-11-10")
      @invoice_3 = create(:invoice, customer: @customer_1, created_at: "2011-09-17")
      @invoice_4 = create(:invoice, customer: @customer_1, created_at: "2010-12-31")
  
      @invoice_items_1 = create(:invoice_item, invoice: @invoice_1)
      @invoice_items_2 = create(:invoice_item, invoice: @invoice_2)
      @invoice_items_3 = create(:invoice_item, status: 1, invoice: @invoice_3)
      @invoice_items_4 = create(:invoice_item, status: 2, invoice: @invoice_4)
    end

    describe ".incomplete_invoices" do
      it "lists incomplete invoices" do
        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1])

        invoice_5 = create(:invoice, customer: @customer_1)
        invoice_items_5 = create(:invoice_item, invoice: invoice_5)

        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1, invoice_5])
      end

      it "lists incomplete invoices from oldest to newest" do
        expect(Invoice.incomplete_invoices).to eq([@invoice_3, @invoice_2, @invoice_1])

        invoice_5 = create(:invoice, customer: @customer_1, created_at: "2012-12-09")
        invoice_items_5 = create(:invoice_item, invoice: invoice_5)

        expect(Invoice.incomplete_invoices).to eq([@invoice_3, invoice_5, @invoice_2, @invoice_1])
      end
    end
  end

  describe "instance_method" do
    before do
      @merchant_1 = create(:merchant)

      @item_1 = create(:item)
      @item_2 = create(:item)
      @item_3 = create(:item)

      @customer_1 = create(:customer)

      @invoice_1 = @customer_1.invoices.create!(status: 1, created_at: "2015-12-09")
      @invoice_2 = @customer_1.invoices.create!(status: 2, created_at: "2013-11-10")

      @invoice_item_1 = InvoiceItem.create!(item_id: @item_1.id, invoice_id: @invoice_1.id, quantity: 1, unit_price: 2500, status: 0)
      @invoice_item_2 = InvoiceItem.create!(item_id: @item_2.id, invoice_id: @invoice_1.id, quantity: 2, unit_price: 1000, status: 1)
      @invoice_item_3 = InvoiceItem.create!(item_id: @item_3.id, invoice_id: @invoice_1.id, quantity: 3, unit_price: 5000, status: 2)
    end

    describe "#format_date_created"
      it "formats the created_at date" do
        expect(@invoice_1.format_date_created).to eq("Wednesday, December 09, 2015")
        expect(@invoice_2.format_date_created).to eq("Sunday, November 10, 2013")
      end

    describe "#total_revenue" do
      it "calculates an invoice's total revenue" do
        expect(@invoice_1.total_revenue).to eq(19500)
      end
    end
  end
end
