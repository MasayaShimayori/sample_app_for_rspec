require 'rails_helper'

RSpec.describe "Usersessions", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン前' do
    before do
      visit login_path
    end
    context 'フォームの入力値が正常' do
      it 'ログイン処理が成功する' do
        fill_in 'Email', with: user.email
        fill_in 'Password', with: '123'
        click_button 'Login'
        expect(page).to have_content('Login successful'), 'フラッシュメッセージ「Login successful」が表示されません'
        expect(current_path).to eq(root_path), 'ルートパスにリダイレクトされません'
      end
    end
    context 'フォームが未入力' do
      it 'ログイン処理が失敗する' do
        fill_in 'Email', with: nil
        fill_in 'Password', with: '123'
        click_button 'Login'
        expect(page).to have_content('Login failed'), 'フラッシュメッセージ「Login failed」が表示されません'
        expect(current_path).to eq(login_path), 'ログインページに戻りません'
      end
    end
  end

  describe 'ログイン後' do
    context 'ログアウトボタンをクリック' do
      it 'ログアウト処理が成功する' do
        login(user)
        click_on 'Logout'
        expect(page).to have_content('Logged out'), 'フラッシュメッセージ「Logged out」が表示されません'
        expect(current_path).to eq(root_path), 'ルートパスに遷移しません'
      end
    end
  end
end
