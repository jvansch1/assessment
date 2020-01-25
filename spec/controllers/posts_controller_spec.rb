require 'rails_helper'

describe PostsController do
  describe "#index" do
    context "with a single tag" do
      let(:expected_response) {
        File.read("spec/fixtures/tech_tag_response.json")
      }

      it "will return the expected posts with the tech tag" do
        get :index, params: { tags: 'tech' }
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected_response))

        JSON.parse(response.body)['posts'].each do |post|
          expect(post['tags'].include?('tech')).to eq(true)
        end
      end

      it "will sort when sortBy id is included" do
        get :index, params: { tags: 'tech', sortBy: 'id' }
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected_response))

        ids = JSON.parse(response.body)['posts'].map { |post| post['id'] }
        expect(ids.sort).to eq(ids)
      end

      it "will sort when another valid key is passed" do
        get :index, params: { tags: 'tech', sortBy: 'popularity' }

        popularity = JSON.parse(response.body)['posts'].map { |post| post['popularity'] }
        expect(popularity.sort).to eq(popularity)
      end

      it "will sort correctly when desc is passed" do
        get :index, params: { tags: 'tech', sortBy: 'popularity', direction: 'desc' }

        popularity = JSON.parse(response.body)['posts'].map { |post| post['popularity'] }
        expect(popularity).to eq(popularity.sort.reverse)
      end

      it "will return an error with incorrect sortBy and direction params" do
        get :index, params: { tags: 'tech', sortBy: 'popurity', direction: 'dec' }

        expect(JSON.parse(response.body)).to eq({"direction"=>"direction parameter is invalid", "sortBy"=>"sortBy parameter is invalid"})
      end

      it "will return an error with no tag params" do
        get :index, params: { sortBy: 'popurity', direction: 'dec' }
        expect(JSON.parse(response.body)).to eq({"error"=>"Tags parameter is required"})
      end
    end

    context "with multiple tags" do
      let(:expected_response) {
        File.read("spec/fixtures/tech_science_tag_response.json")
      }

      it "will return the expected posts with the tech or science tag tag" do
        get :index, params: { tags: 'tech,science' }
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected_response))

        JSON.parse(response.body)['posts'].each do |post|
          expect(post['tags'].include?('tech') || post['tags'].include?('science')).to eq(true)
        end
      end

      it "will not have posts with duplicate ids" do
        get :index, params: { tags: 'tech,science' }
        expect(JSON.parse(response.body)).to eq(JSON.parse(expected_response))

        ids = JSON.parse(response.body)['posts'].map { |post| post['id'] }
        expect(ids).to eq(ids.uniq)
      end
    end
  end
end
