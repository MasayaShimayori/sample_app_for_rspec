require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user){ create(:user) }
  let(:other_user){ create(:user) }
  let(:task){ create(:task, user: user) }
  before do
    driven_by(:rack_test)
  end
  describe 'ログイン前' do
    after do
      expect(page).to have_content('Login require')
      expect(current_path).to eq(login_path)
    end
    context 'タスクの新規作成' do
      it 'ログインページにリダイレクトされること' do
        visit new_task_path
      end
    end
    context 'タスクの編集' do
      it 'ログインページにリダイレクトされること' do
        visit edit_task_path(task)
      end
    end
  end
  describe 'ログイン後' do
    context '自分のタスク' do
      before do
        login(user)
      end
      it 'タスク新規作成ができること' do
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
      end
      it 'タスク編集ができること' do
        visit edit_task_path(task)
        fill_in 'Title', with: 'edit_title'
        click_button 'Update Task'
        expect(page).to have_content('Task was successfully updated.')
        expect(page).to have_content('edit_title')
      end
      it 'タスク削除ができること' do
        task_destroy = create(:task, user: user)
        visit tasks_path
        click_link 'Destroy'
        expect(page).to have_content('Task was successfully destroyed.')
        expect(current_path).to eq(tasks_path)
      end
    end
    context '他人のタスク' do
      it 'タスク編集ページに遷移できないこと' do
        login(other_user)
        visit edit_task_path(task)
        expect(page).to have_content('Forbidden access.')
        expect(current_path).to eq(root_path)
      end
    end
  end
end
