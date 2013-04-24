require 'spec_helper'

describe User do
  
  before { @user = User.new(name: "Example User", email: "user@example.com", 
                            password: "foobar", password_confirmation: "foobar") }
      
  subject { @user }
  
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:admin)}
  it { should respond_to(:microposts)}
  it { should respond_to(:feed) }
  it { should respond_to(:relationships) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:reverse_relationships) }
  it { should respond_to(:followers) }
  it { should respond_to(:followed_users) }
  it { should respond_to(:following?) }
  it { should respond_to(:follow!) }
  it { should respond_to(:unfollow!) }
  
  it { should be_valid }
  it { should_not be_admin }
  
  # name tests
  
  describe "when name is not present" do
    before { @user.name = " " }
    
    it { should_not be_valid }
  end
  
  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    
    it { should_not be_valid }
  end
  
  # email tests
  
  describe "when email is not present" do
    before { @user.email = " " }
    
    it { should_not be_valid }
  end
  
  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |a|
        @user.email = a
        expect(@user).not_to be_valid
      end
    end
  end
  
  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp ab@baz.cn]
      addresses.each do |a|
        @user.email = a
        expect(@user).to be_valid
      end
    end
  end
  
  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end
      
    it { should_not be_valid }
  end
  
  describe "email address with mixed case" do
    let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

    it "should be saved as all lower-case" do
      @user.email = mixed_case_email
      @user.save
      expect(@user.reload.email).to eql(mixed_case_email.downcase)
    end
  end

  # password tests
  
  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = "" }
    it { should_not be_valid }
  end
  
  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end
  
  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it {should_not be_valid}
  end
  
  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by(email: @user.email) }
    
    describe "with valid password" do
      it { should eql(found_user.authenticate(@user.password)) }
    end
    
    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
      
      it { should_not eql(user_for_invalid_password) }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end
     
  #remember token
  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank } 
  end
  
  #admin tests
  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end
    
    it { should be_admin }
  end
  
  #micropost tests
  describe "micropost associations" do
    
    before {@user.save}
    let!(:older_micropost) do 
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end
    
    it "should have the right microposts in the right order" do
      expect(@user.microposts.to_a).to eql([newer_micropost, older_micropost])
    end
    
    it "should destroy associated microposts" do
      microposts = @user.microposts.dup.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end
    
    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end
      let(:followed_user) { FactoryGirl.create(:user) }    
      
      before do
        @user.follow!(followed_user)
        3.times { followed_user.microposts.create!(content: "Lorem ipsum") }
      end
      
      its(:feed) {should include(newer_micropost)}
      its(:feed) {should include(older_micropost)}
      its(:feed) {should_not include(unfollowed_post)}
      its(:feed) do
        followed_user.microposts.each do |micropost|
          should include(micropost)
        end
      end
    end
  end
  
  describe "following" do
    let(:other_user) { FactoryGirl.create(:user) } 
    before do
      @user.save
      @user.follow!(other_user)
    end
    
    it { should be_following(other_user) }
    its(:followed_users) { should include(other_user) }
    
    describe "followed user" do
      subject { other_user }
      its(:followers) { should include(@user) }
    end
    
    describe "and unfollowing" do
      before { @user.unfollow!(other_user) }
      
      it { should_not be_following(other_user) }
      its(:followed_users) { should_not include(other_user) }
    end
  end
end
