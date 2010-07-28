require "google4r/checkout"

class TaxTableFactory

  def effective_tax_tables_at(time)
    table1 = Google4R::Checkout::TaxTable.new(false)
    table1.name = "Default Tax Table"
    table1.create_rule do |rule|
      # Set MI tax to 8%
      rule.area = Google4R::Checkout::UsStateArea.new("MI")
      rule.rate = 0.06
    end
    
    [ table1 ]
    end
    
end
