require 'spec_helper'

describe "primary_key" do
  it "should be bigint with limit: 8" do
    pkcol = Goods.columns_hash[Goods.primary_key]

    expect(pkcol.unsigned?).to be_truthy
    expect(pkcol.limit).to be 8 if ActiveRecord::VERSION::MAJOR == 4
  end
end
