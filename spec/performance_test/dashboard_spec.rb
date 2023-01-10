require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  render_views
  NO_OF_QUERIES = 1
  SPEC_STATS= {}
  describe "Performance Test" do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    before do
      @blog ||= create(:blog)
      @henri = create(:user, :as_admin)
      sign_in @henri
      # get :index
      # get :index_in_pipeline
    end

    it "Render dashboard controller in non-pipeline mode" do

      time = Benchmark.measure{
        NO_OF_QUERIES.times do
          get :index
        end
      }
      SPEC_STATS["non-pipeline mode with 30ms latency"]=time.real
      time = Benchmark.measure{
        NO_OF_QUERIES.times do
          get :index
        end
      }
      SPEC_STATS["pipeline mode with 30ms latency"]=time.real
      print(SPEC_STATS)
    end

    xit "Render dashboard controller in pipeline mode" do
      time = Benchmark.measure{
        NO_OF_QUERIES.times do
          get :index
        end
      }
      SPEC_STATS["pipeline mode with 30ms latency"]=time.real
      print(SPEC_STATS)
    end



    xit "Render dashboard controller in non-pipeline mode with Toxiproxy latency" do
      Toxiproxy[:postgres_proxy].toxic(:latency, latency: 60).apply do
        time = Benchmark.measure{
          NO_OF_QUERIES.times do
            get :index
          end
        }
        SPEC_STATS["non-pipeline mode with x ms latency"]=time.real
        print(SPEC_STATS)
        end
      end
    end
end