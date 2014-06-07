require 'spec_helper'

describe "after option" do
  before :all do
    AddColumnAfterToGoodsTable.change
  end

  it "insert 'added_after_name' column after 'name' column" do
    name_num = added_after_name_num = 0

    Goods.columns.each_with_index do |column, i|
      name_num = i if column.name == "name"
      added_after_name_num = i if column.name == "added_after_name"
    end

    expect(name_num + 1).to eq(added_after_name_num)
  end
end
