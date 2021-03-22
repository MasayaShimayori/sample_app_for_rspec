require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }

  describe 'ログイン前' do
    describe 'ユーザー新規登録' do
      before do
        visit sign_up_path
      end

      context 'フォームの入力値が正常' do
        it 'ユーザーの新規作成が成功する' do
          user = build(:user)
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          fill_in 'Password confirmation', with: user.password
          click_button 'SignUp'
          expect(page).to have_content('User was successfully created.'),'フラッシュメッセージ「User was successfully created.」が表示されていません'
          expect(current_path).to eq(login_path), 'ログインページに遷移していません' 
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの新規作成が失敗する' do
          user_without_email = build(:user)
          fill_in 'Email', with: ''
          fill_in 'Password', with: user_without_email.password
          fill_in 'Password confirmation', with: user_without_email.password
          click_button 'SignUp'
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content("Email can't be blank"), 'メールアドレス未入力でユーザー登録できてしまいます'
          expect(current_path).to eq(users_path), 'サインアップページに戻りません'
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの新規作成が失敗する' do
          user_with_same_email = build(:user, email: user.email)
          fill_in 'Email', with: user_with_same_email.email
          fill_in 'Password', with: user_with_same_email.password
          fill_in 'Password confirmation', with: user_with_same_email.password
          click_button 'SignUp'
          expect(page).to have_content '1 error prohibited this user from being saved'
          expect(page).to have_content('Email has already been taken'),'フラッシュメッセージ「Email has already been taken」が表示されていません'
          expect(current_path).to eq(users_path), 'ログインページに遷移していません' 
        end
      end
    end

    describe 'マイページ' do
      context 'ログインしていない状態' do
        it 'マイページへのアクセスが失敗する' do
          visit user_path(user)
          expect(page).to have_content('Login required'), 'フラッシュメッセージ「Login required」が表示されません'
          expect(current_path).to eq(login_path), 'ログインページに遷移されません'
        end
      end
    end
  end

  describe 'ログイン後' do
    let(:user_already) { create(:user) }
    before { login(user) }

    describe 'ユーザー編集' do
      before do
        visit edit_user_path(user)
      end
      context 'フォームの入力値が正常' do
        it 'ユーザーの編集が成功する' do
          fill_in 'Email', with: 'edit@user.com'
          fill_in 'Password', with: '456'
          fill_in 'Password confirmation', with: '456'
          click_button 'Update'
          expect(page).to have_content('User was successfully updated.')
          expect(current_path).to eq(user_path(user))
          expect(page).to have_content('edit@user.com')
        end
      end
      context 'メールアドレスが未入力' do
        it 'ユーザーの編集が失敗する' do
          fill_in 'Email', with: nil
          fill_in 'Password', with: '123'
          fill_in 'Password confirmation', with: '123'
          click_button 'Update'
          expect(page).to have_content("Email can't be blank")
          expect(current_path).to eq(user_path(user))
        end
      end
      context '登録済のメールアドレスを使用' do
        it 'ユーザーの編集が失敗する' do
          fill_in 'Email', with: user_already.email
          fill_in 'Password', with: '123'
          fill_in 'Password', with: '123'
          click_button 'Update'
          expect(page).to have_content('Email has already been taken')
          expect(current_path).to eq(user_path(user))
        end
      end
      context '他ユーザーの編集ページにアクセス' do
        it '編集ページへのアクセスが失敗する' do
          visit edit_user_path(user_already)
          expect(page).to have_content('Forbidden access.')
          expect(current_path).to eq(user_path(user))
        end
      end
    end

    describe 'マイページ' do
      context 'タスクを作成' do
        it '新規作成したタスクが表示される' do
          task = create(:task, user: user)
          visit user_path(user)
          expect(page).to have_content('You have 1 task.')
          expect(page).to have_content(task.title)
          expect(page).to have_content(task.status)
          expect(page).to have_link('Show')
          expect(page).to have_link('Edit')
          expect(page).to have_link('Destroy')
        end
      end
    end
  end
end
