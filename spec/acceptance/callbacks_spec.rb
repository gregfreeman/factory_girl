require 'spec_helper'
require 'acceptance/acceptance_helper'

describe "callbacks" do
  before do
    define_model("User", :first_name => :string, :middle_name => :string, :last_name => :string)

    FactoryGirl.define do
      factory :user_with_callbacks, :class => :user do
        after_stub   { |user| user.first_name = 'Stubby' }
        after_build  { |user| user.first_name = 'Buildy' }
        after_create { |user| user.last_name  = 'Createy' }
        before_build { |user| user.middle_name = 'Beforey' }
      end

      factory :user_with_inherited_callbacks, :parent => :user_with_callbacks do
        after_stub { |user| user.last_name = 'Double-Stubby' }
      end
      factory :user_with_dynamic_values, :parent => :user_with_callbacks do
        before_build { |user| user.last_name = 'Double-Stubby' }
      end
      factory :user_with_callback_dynamic, :class => :user do
        before_build { |user| @dynamic_val='Dynamic Before' }
        middle_name { |user| @dynamic_val }
      end
      factory :user_with_callback_override, :class => :user do
        middle_name 'Before override'
        before_build { |user| user.middle_name = 'Beforey' }

      end
    end
  end

  it "runs the after_stub callback when stubbing" do
    user = FactoryGirl.build_stubbed(:user_with_callbacks)
    user.first_name.should == 'Stubby'
  end

  it "runs the after_build callback when building" do
    user = FactoryGirl.build(:user_with_callbacks)
    user.first_name.should == 'Buildy'
  end

  it "runs both the after_build and after_create callbacks when creating" do
    user = FactoryGirl.create(:user_with_callbacks)
    user.first_name.should == 'Buildy'
    user.last_name.should == 'Createy'
  end

  it "runs the before_build callback when building" do
    user = FactoryGirl.build(:user_with_callbacks)
    user.middle_name.should == 'Beforey'
  end
   
  it "runs the before_build callback when creating" do
    user = FactoryGirl.create(:user_with_callbacks)
    user.middle_name.should == 'Beforey'
  end
  
  it "runs the before_build callback when stubbing" do
    user = FactoryGirl.build_stubbed(:user_with_callbacks)
    user.middle_name.should == 'Beforey'
  end
  
  it "runs the before_build callback when creating dynamically" do
    user = FactoryGirl.create(:user_with_callback_dynamic)
    user.middle_name.should == 'Dynamic Before'
  end

  it "runs the before_build callback does not run after attribute assignment" do
    user = FactoryGirl.create(:user_with_callback_override)
    user.middle_name.should == 'Before override'
  end

  it "runs both the after_stub callback on the factory and the inherited after_stub callback" do
    user = FactoryGirl.build_stubbed(:user_with_inherited_callbacks)
    user.first_name.should == 'Stubby'
    user.last_name.should == 'Double-Stubby'
  end
end
