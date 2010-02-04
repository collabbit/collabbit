require 'test_helper'

class AdminTest < ActiveSupport::TestCase
  fixtures :all
  
  should_not_allow_mass_assignment_of :crypted_password, :salt

  should_allow_mass_assignment_of :email
  should_not_allow_values_for :email, 'foo', ' ', 'a b@foo.com'
  should_allow_values_for :email, 'eli@collabbit.org', 'foo@bar.jp', 'foo+Bar@baz.qux'
  should_validate_presence_of :email
  
  context "An Admin instance" do
    setup do
      @admin = Admin.first
    end
    should "update the crypted password" do
      newPass = "newPass#{rand(1000)}"
      @admin.password = newPass
      @admin.password_confirmation = newPass
      @admin.save
      assert_equal @admin.crypted_password, @admin.generate_crypted_password(newPass)
    end
  end
end