require 'rails_helper'

describe "Authentication" do
	subject { page }

	describe "signin page" do
		before { visit signin_path }

		it { should have_content('Sign In') }
		it { should have_title(full_title('Sign In')) }
	end

	describe 'signin' do
		before { visit signin_path }

		describe "with invalid information" do
			before { click_button "Sign In" }

			it { should have_title('Sign In') }
			it { should have_error_message('Invalid') }

			describe "after visiting another page" do
				before { click_link "Help" }
				it { should_not have_selector('div.alert.alert-error') }
			end
		end

		describe "retains form info on invalid signin" do
			before do
				fill_in "Email", with: "user@example.com"
				click_button "Sign In"
			end

			it { should have_field('Email', with: 'user@example.com') }
		end

		describe "with valid information" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			it { should have_title(user.name) }
			it { should have_link('Users', href: users_path) }
			it { should have_link('Profile', href: user_path(user)) }
			it { should have_link('Settings', href: edit_user_path(user)) }
			it { should have_link('Sign Out', href: signout_path) }
			it { should_not have_link('Sign In', href: signin_path) }

			describe "followed by signout" do
				before { click_link "Sign Out" }
				it { should have_link('Sign In') }
			end
		end
	end

	describe "authorization" do

		describe "as non-admin user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:non_admin) { FactoryGirl.create(:user) }

			before { sign_in non_admin, no_capybara: true }

			describe "submitting a DELETE request to the Users#action" do
				before { delete user_path(user) }
				specify { expect(response).to redirect_to(root_url) }
			end
		end

		describe "as admin user" do
			let(:admin) { FactoryGirl.create(:admin) }
			before { sign_in admin, no_capybara: true }

			describe "when attempting to delete themselves" do
				before { delete user_path(admin) }
				specify { expect(response).to redirect_to(root_url) }
			end
		end

		describe "for signed-in users" do
			let(:user) { FactoryGirl.create(:user) }
			before { sign_in user }

			describe "when attempting to visit 'new' page" do
				before { visit new_user_path }
				it { should have_title('') } # redirected to home page
			end

			describe "when attempting to visit 'create' page" do
				before { put user_path(user) }
				it { should have_title('') } # redirected to home page
			end
		end

		describe "for non-signed-in users" do
			let(:user) { FactoryGirl.create(:user) }

			describe "when attempting to visit a protected page" do
				before do
					visit edit_user_path(user)
					fill_in "Email", with: user.email
					fill_in "Password", with: user.password
					click_button "Sign In"
				end

				describe "after signing in" do
					it "should render the desired protected page" do
						expect(page).to have_title("Edit User")
					end

					describe "when signing in again" do
						before do
							click_link "Sign Out"
							visit signin_path
							fill_in "Email", with: user.email
							fill_in "Password", with: user.password
							click_button "Sign In"
						end

						it "should render the default (profile) page" do
							expect(page).to have_title(user.name)
						end
					end
				end
			end

			describe "in the Users controller" do

				describe "visiting the edit page" do
					before { visit edit_user_path(user) }
					it { should have_title('Sign In') }
				end

				describe "submitting to the update action" do
					before { patch user_path(user) }
					specify { expect(response).to redirect_to signin_path }
				end

				describe "visiting the user index" do
					before { visit users_path }
					it { should have_title('Sign In') }
				end

				describe "visiting the following page" do
					before { visit following_user_path(user) }
					it { should have_title('Sign In') }
				end

				describe "visiting the followers page" do
					before { visit followers_user_path(user) }
					it { should have_title('Sign In') }
				end
			end

			describe "in the Microposts controller" do
				describe "submitting to the create action" do
					before { post microposts_path }
					specify { expect(response).to redirect_to(signin_path) }
				end

				describe "submitting to the destroy action" do
					before { delete micropost_path(FactoryGirl.create(:micropost)) }
					specify { expect(response).to redirect_to(signin_path) }
				end
			end

			describe "in the Relationships controller" do
				describe "submitting to the create action" do
					before { post relationships_path }
					specify { expect(response).to redirect_to(signin_path) }
				end

				describe "submitting to the delete action" do
					before { delete relationship_path(1) }
					specify { expect(response).to redirect_to(signin_path) }
				end
			end
		end

		describe "as wrong user" do
			let(:user) { FactoryGirl.create(:user) }
			let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
			before { sign_in user, no_capybara: true}

			describe "submitting GET request to the Users#edit action" do
				before { get edit_user_path(wrong_user) }
				specify { expect(response.body).not_to match(full_title('Edit User')) }
				specify { expect(response).to redirect_to(root_url) }
			end

			describe "submitting PATCH request to the wrong update action" do
				before { patch user_path(wrong_user) }
				specify { expect(response).to redirect_to root_url }
			end
		end
	end
end
