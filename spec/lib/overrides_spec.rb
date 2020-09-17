# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
module Decidim::ActionDelegator
  checksums = [
    {
      package: "decidim-admin",
      files: {
        "/app/views/layouts/decidim/admin/users.html.erb" => "8d2622bcea84aa844896123499619bc3"
      }
    }, {
      package: "decidim-consultations",
      files: {
        # views
        "/app/views/decidim/consultations/consultations/_question.html.erb" => "e0490411ca3af6573cc736b297cbe6c8",
        "/app/views/decidim/consultations/consultations/show.html.erb" => "84a1569b796f724efa304b9dfc40f68a",
        "/app/views/decidim/consultations/question_votes/update_vote_button.js.erb" => "a675fe780e77e8766beef999112a8fcb",
        "/app/views/decidim/consultations/questions/_vote_button.html.erb" => "036bbb6a3e37062ed37325da8d48ed36",
        "/app/views/decidim/consultations/questions/_vote_modal.html.erb" => "b23948e4ed7e0360a09faef326bc3664",
        "/app/views/decidim/consultations/questions/_vote_modal_confirm.html.erb" => "7eb753c457e9a5adc6c16efd155ba434",
        # monkeypatches
        "/app/commands/decidim/consultations/vote_question.rb" => "8d89031039a1ba2972437d13687a72b5",
        "/app/controllers/decidim/consultations/question_votes_controller.rb" => "69bf764e99dfcdae138613adbed28b84",
        "/app/forms/decidim/consultations/vote_form.rb" => "d2b69f479b61b32faf3b108da310081a"
      }
    }
  ]

  describe "Overriden files", type: :view do
    checksums.each do |item|
      # rubocop:disable Rails/DynamicFindBy
      spec = ::Gem::Specification.find_by_name(item[:package])
      # rubocop:enable Rails/DynamicFindBy
      item[:files].each do |file, signature|
        it "#{spec.gem_dir}#{file} matches checksum" do
          expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
        end
      end
    end

    private

    def md5(file)
      Digest::MD5.hexdigest(File.read(file))
    end
  end
end
