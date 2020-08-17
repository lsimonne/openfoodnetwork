require "spec_helper"

feature "Uploading Terms and Conditions PDF" do
  include WebHelper
  include AuthenticationHelper

  context "as an Enterprise user", js: true do
    let(:enterprise_user) { create(:user, enterprise_limit: 1) }
    let(:distributor) { create(:distributor_enterprise, name: "First Distributor") }

    before do
      enterprise_user.enterprise_roles.build(enterprise: distributor).save!

      login_as enterprise_user
      visit edit_admin_enterprise_path(distributor)
    end

    describe "images for an enterprise" do
      def go_to_business_details
        within(".side_menu") do
          click_link "Business Details"
        end
      end

      let(:white_pdf_file_name) { Rails.root.join("app", "assets", "images", "logo-white.pdf") }
      let(:black_pdf_file_name) { Rails.root.join("app", "assets", "images", "logo-black.pdf") }

      before do
        # Create fake PDFs from PNG images
        FileUtils.cp(Rails.root.join("app", "assets", "images", "logo-white.png"), white_pdf_file_name)
        FileUtils.cp(Rails.root.join("app", "assets", "images", "logo-black.png"), black_pdf_file_name)
  
        go_to_business_details
      end

      scenario "uploading terms and conditions" do
        # Add PDF
        attach_file "enterprise[terms_and_conditions]", white_pdf_file_name
        click_button "Update"
        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_business_details
        expect(page).to have_selector("a[href*='logo-white.pdf']")

        # Replace PDF
        attach_file "enterprise[terms_and_conditions]", black_pdf_file_name
        click_button "Update"
        expect(page).to have_content("Enterprise \"#{distributor.name}\" has been successfully updated!")

        go_to_business_details
        expect(page).to have_selector("a[href*='logo-black.pdf']")
      end

      after do
        # Delete fake PDFs
        FileUtils.rm_f(white_pdf_file_name)
        FileUtils.rm_f(black_pdf_file_name)
      end
    end
  end
end
