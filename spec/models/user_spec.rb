require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'database columns' do
    it { should have_db_column(:email) }
    it { should have_db_column(:encrypted_password) }
  end
end
