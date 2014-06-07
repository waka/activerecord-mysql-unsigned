require 'spec_helper'

describe "INT column" do

  before :all do
    ChangePrimaryKeyToGoodsTable.change
    ChangeColumnToUsersTable.change
    AddColumnToUsersTable.change
  end

  before(:each) do
    @user = User.new(name: "bob")
  end

  it "max value of signed int" do
    @user.signed_int = 2147483647
    expect(@user.save).to be_true
  end

  it "max value of unsigned int" do
    @user.unsigned_int = 4294967295
    expect(@user.save).to be_true
  end

  it "allowed minus value of signed int" do
    @user.signed_int = -2147483648
    expect(@user.save).to be_true
  end

  it "not allowed minus value of unsigned int" do
    @user.unsigned_int = -2147483648

    if ActiveRecord::VERSION::MAJOR == 4
      begin
        @user.save
        expect(true).to be_false # should not be reached here
      rescue => e
        expect(e).to be_an_instance_of ActiveRecord::StatementInvalid
      end
    else
      @user.save
      @user.reload
      expect(@user.unsigned_int).to be 0 # saved 0
    end
  end

  it "unsigned column has 'unsigned' attribute" do
    signed_int_col = User.columns[2]
    expect(signed_int_col.unsigned).to be_false

    unsigned_int_col = User.columns[3]
    expect(unsigned_int_col.unsigned).to be_true
  end
end
