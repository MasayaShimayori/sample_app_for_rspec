require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user){ create(:user) }
  let(:other_user){ create(:user) }
  let(:task){ create(:task, user: user) }

  describe 'ログイン前' do
    describe 'ページ遷移確認' do
      context 'タスク新規作成ページにアクセス' do
        it 'ログインページにリダイレクトされること' do
          visit new_task_path
          expect(page).to have_content('Login require')
          expect(current_path).to eq(login_path)
        end
      end
      context 'タスク編集ページにアクセス' do
        it 'ログインページにリダイレクトされること' do
          visit edit_task_path(task)
          expect(page).to have_content('Login require')
          expect(current_path).to eq(login_path)
        end
      end
      context 'タスクの詳細ページにアクセス' do
        it '詳細ページが表示' do
          visit task_path(task)
          expect(page).to have_content task.title
          expect(current_path).to eq task_path(task)
        end
      end
      context 'タスク一覧ページアクセス' do
        it 'すべてのユーザーのタスク情報が表示される' do
          task_list = create_list(:task, 3)
          visit tasks_path
          expect(page).to have_content task_list[0].title
          expect(page).to have_content task_list[1].title
          expect(page).to have_content task_list[2].title
          expect(current_path).to eq tasks_path
        end
      end
    end
  end

  describe 'ログイン後' do
    before { login(user) }

    describe 'タスク新規登録' do
      context 'フォーム入力値が正常' do
        it 'タスク作成が成功する' do
          visit new_task_path
          task_new = build(:task, user: user)
          fill_in 'Title', with: task_new.title
          fill_in 'Content', with: task_new.content
          select task_new.status, from: 'Status'
          fill_in 'Deadline', with: task_new.deadline
          click_button 'Create Task'
          expect(page).to have_content('Task was successfully created.')
          expect(page).to have_content(task_new.title)
          expect(page).to have_content(task_new.content)
          expect(page).to have_content(task_new.status)
          expect(page).to have_content(task_new.deadline.strftime('%Y/%-m/%-d %-H:%-M'))
          expect(current_path).to eq '/tasks/1'
        end
      end
      context 'タイトルが未入力' do
        it 'タスク作成が失敗する' do
          visit new_task_path
          task_without_title = build(:task, user: user)
          fill_in 'Title', with: ''
          fill_in 'Content', with: task_without_title.content
          select task_without_title.status, from: 'Status'
          fill_in 'Deadline', with: task_without_title.deadline
          click_button 'Create Task'
          expect(page).to have_content('1 error prohibited this task from being saved:')
          expect(page).to have_content("Title can't be blank")
          expect(current_path).to eq tasks_path
        end
      end
      context '登録済のタイトル入力' do
        it 'タスク作成が失敗する' do
          visit new_task_path
          task_already = build(:task, user: user, title: task.title)
          fill_in 'Title', with: task_already.title
          fill_in 'Content', with: task_already.content
          select task_already.status, from: 'Status'
          fill_in 'Deadline', with: task_already.deadline
          click_button 'Create Task'
          expect(page).to have_content('1 error prohibited this task from being saved:')
          expect(page).to have_content('Title has already been taken')
          expect(current_path).to eq tasks_path
        end
      end
    end

    describe 'タスク編集' do
      context 'フォーム入力値が正常' do
        it 'タスク編集が成功する' do
          visit edit_task_path(task)
          fill_in 'Title', with: 'edit_title'
          select :done, from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content('Task was successfully updated.')
          expect(page).to have_content('edit_title')
          expect(page).to have_content('done')
          expect(current_path).to eq task_path(task)
        end
      end
      context 'タイトルが未入力' do
        it 'タスク編集が失敗する' do
          visit edit_task_path(task)
          fill_in 'Title', with: ''
          select :done, from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content('1 error prohibited this task from being saved')
          expect(page).to have_content("Title can't be blank")
          expect(current_path).to eq task_path(task)
        end
      end
      context '登録済みのタイトル' do
        it 'タスク編集が失敗する' do
          task_same_title = create(:task)
          visit edit_task_path(task)
          fill_in 'Title', with: task_same_title.title
          select :todo, from: 'Status'
          click_button 'Update Task'
          expect(page).to have_content('1 error prohibited this task from being saved')
          expect(page).to have_content('Title has already been taken')
          expect(current_path).to eq task_path(task)
        end
      end
    end

    describe 'タスク削除' do
      it 'タスク削除ができること' do
        task_destroy = create(:task, user: user)
        visit tasks_path
        click_link 'Destroy'
        expect(page.accept_confirm).to eq 'Are you sure?'
        expect(page).to have_content('Task was successfully destroyed.')
        expect(current_path).to eq(tasks_path)
        expect(page).not_to have_content task.title
      end
    end

#    describe '他人のタスク' do
#      it 'タスク編集ページに遷移できないこと' do
#        login(other_user)
#        visit edit_task_path(task)
#        expect(page).to have_content('Forbidden access.')
#        expect(current_path).to eq(root_path)
#      end
#    end
  end
end
