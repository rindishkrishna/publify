require 'rails_helper'

RSpec.describe Admin::DashboardController, type: :controller do
  render_views
  describe "Benchmark Testing" do
    before do
      @henri = create(:user, :as_admin)
      sign_in @henri
      get :index
      get :index_in_pipeline
      get :index_on_steroids
      get :index_on_steroids_in_pipeline
    end
    def get_benchmark_results
      index_pipeline_benchmarks = []
      index_with_load_in_pipeline_benchmarks = []
      index_non_pipeline_benchmarks = []
      benchmark_count = 100
      benchmark_count.times do
        index_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
        index_with_load_in_pipeline_benchmarks << Benchmark.ms {
          get :index_in_pipeline
        }
      end

      ActiveRecord::Base.establish_connection :test_non_pipeline
      benchmark_count.times do
        index_non_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
      end
      ActiveRecord::Base.establish_connection :test

      return [index_pipeline_benchmarks, index_with_load_in_pipeline_benchmarks, index_non_pipeline_benchmarks]
    end

    def get_benchmark_results_on_steroids
      index_pipeline_benchmarks = []
      index_with_load_in_pipeline_benchmarks = []
      index_non_pipeline_benchmarks = []
      benchmark_count = 100
      benchmark_count.times do
        index_pipeline_benchmarks << Benchmark.ms {
          get :index_on_steroids
        }
        index_with_load_in_pipeline_benchmarks << Benchmark.ms {
          get :index_on_steroids_in_pipeline
        }
      end

      ActiveRecord::Base.establish_connection :test_non_pipeline
      benchmark_count.times do
        index_non_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
      end
      ActiveRecord::Base.establish_connection :test

      return [index_pipeline_benchmarks, index_with_load_in_pipeline_benchmarks, index_non_pipeline_benchmarks]
    end

    it "pipeline mode should perform better than non-pipeline mode" do
      benchmark_results = get_benchmark_results
      require 'descriptive_statistics'
      index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
      index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
      index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


      puts "95% : In Pipeline but without load : #{benchmark_results[0].percentile(95)} ; In pipeline with load : #{benchmark_results[1].percentile(95)}, Not in pipeline #{benchmark_results[2].percentile(95)}"
      puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
      expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
    end

    it "pipeline mode should perform better than non-pipeline mode with network latency of 10 ms" do
      Toxiproxy[:postgres_proxy].toxic(:latency, latency: 10).apply do
        benchmark_results = get_benchmark_results
        require 'descriptive_statistics'
        index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
        index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
        index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


        puts "95% : In Pipeline but without load : #{benchmark_results[0].percentile(95)} ; In pipeline with load : #{benchmark_results[1].percentile(95)}, Not in pipeline #{benchmark_results[2].percentile(95)}"
        puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
        expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
      end
    end

    it "pipeline mode should perform better than non-pipeline mode with network latency of 10 ms with 11 queries using load_in_pipeline" do
      Toxiproxy[:postgres_proxy].toxic(:latency, latency: 10).apply do
        benchmark_results = get_benchmark_results_on_steroids
        require 'descriptive_statistics'
        index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
        index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
        index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


        puts "95% : In Pipeline but without load : #{benchmark_results[0].percentile(95)} ; In pipeline with load : #{benchmark_results[1].percentile(95)}, Not in pipeline #{benchmark_results[2].percentile(95)}"
        puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
        expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
      end
    end

    it "pipeline mode should perform better than non-pipeline mode in transaction scenarios" do
      ActiveRecord::Base.transaction do
        @henri = create(:user, :as_admin)
      end
      benchmark_results = get_benchmark_results
      require 'descriptive_statistics'
      index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
      index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
      index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


      puts "95% : In Pipeline but without load : #{benchmark_results[0].percentile(95)} ; In pipeline with load : #{benchmark_results[1].percentile(95)}, Not in pipeline #{benchmark_results[2].percentile(95)}"
      puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
      expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
    end
  end
end