require 'spec_helper'

describe "INT/Decimal column" do

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
    expect(@user.save).to be_truthy
  end

  it "max value of unsigned int" do
    @user.unsigned_int = 4294967295
    expect(@user.save).to be_truthy
  end

  it "allowed minus value of signed int" do
    @user.signed_int = -2147483648
    expect(@user.save).to be_truthy
  end

  it "not allowed minus value of unsigned int" do
    @user.unsigned_int = -2147483648

    if strict_mode?
      begin
        @user.save
        expect(true).to be_falsey # should not be reached here
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
    expect(signed_int_col.unsigned).to be_falsey

    unsigned_int_col = User.columns[3]
    expect(unsigned_int_col.unsigned).to be_truthy
  end

  it "allowed minus value of signed decimal" do
    @user.signed_decimal = -10.0
    @user.save
    expect(@user.signed_decimal).to eq(-10.0)
  end

  it "not allowed minus value of unsigned decimal" do
    @user.unsigned_decimal = -10

    if strict_mode?
      begin
        @user.save
        expect(true).to be_falsey # should not be reached here
      rescue => e
        expect(e).to be_an_instance_of ActiveRecord::StatementInvalid
      end
    else
      @user.save
      @user.reload
      expect(@user.unsigned_decimal).to eq BigDecimal("0.00") # saved 0.00
    end
  end

  private

  def strict_mode?
    /STRICT_(?:TRANS|ALL)_TABLES/ =~ ActiveRecord::Base.connection.select_value("SELECT @@SESSION.sql_mode")
  end
end
