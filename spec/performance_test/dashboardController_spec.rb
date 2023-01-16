require 'rails_helper'


BENCHMARK_COUNT = 10
PERCENTILE = 0.95

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

    def transaction_statements
      ActiveRecord::Base.transaction do
        @user = User.create!(name: "anonymous_user", email: generate(:email), password: "password", login: FactoryBot.generate(:user))
        blog = Blog.create()
        @article = Article.create!(title: "A big article", body: "A content with several data",blog: blog)
        @tag = Tag.create!(name: "Tag", blog: blog)
        @note = Note.create!( body: "A content with several data",blog: blog)
      end
      rescue e
        puts "Oops. We tried to do an invalid operation!"
    end

    def get_benchmark_results
      index_pipeline_benchmarks = []
      index_with_load_in_pipeline_benchmarks = []
      index_non_pipeline_benchmarks = []
      BENCHMARK_COUNT.times do
        index_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
        index_with_load_in_pipeline_benchmarks << Benchmark.ms {
          get :index_in_pipeline
        }
      end

      ActiveRecord::Base.establish_connection :test_non_pipeline
      BENCHMARK_COUNT.times do
        index_non_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
      end
      ActiveRecord::Base.establish_connection :test

      [index_pipeline_benchmarks, index_with_load_in_pipeline_benchmarks, index_non_pipeline_benchmarks]
    end

    def get_benchmark_results_on_steroids
      index_pipeline_benchmarks = []
      index_with_load_in_pipeline_benchmarks = []
      index_non_pipeline_benchmarks = []
      BENCHMARK_COUNT.times do
        index_pipeline_benchmarks << Benchmark.ms {
          get :index_on_steroids
        }
        index_with_load_in_pipeline_benchmarks << Benchmark.ms {
          get :index_on_steroids_in_pipeline
        }
      end

      ActiveRecord::Base.establish_connection :test_non_pipeline
      BENCHMARK_COUNT.times do
        index_non_pipeline_benchmarks << Benchmark.ms {
          get :index
        }
      end
      ActiveRecord::Base.establish_connection :test

      [index_pipeline_benchmarks, index_with_load_in_pipeline_benchmarks, index_non_pipeline_benchmarks]
    end

    def get_transaction_benchmark_results
      transaction_pipeline_benchmarks = []
      transaction_non_pipeline_benchmarks = []
      BENCHMARK_COUNT.times do
        transaction_pipeline_benchmarks << Benchmark.ms {
          transaction_statements
        }
      end

      ActiveRecord::Base.establish_connection :test_non_pipeline
      BENCHMARK_COUNT.times do
        transaction_non_pipeline_benchmarks << Benchmark.ms {
          transaction_statements
        }
      end
      ActiveRecord::Base.establish_connection :test

      [transaction_pipeline_benchmarks, transaction_non_pipeline_benchmarks]
    end

    def percentile(values, percentile)
      values_sorted = values.sort
      k = (percentile*(values_sorted.length-1)+1).floor - 1
      f = (percentile*(values_sorted.length-1)+1).modulo(1)

      return values_sorted[k] if values_sorted.length == 1

      values_sorted[k] + (f * (values_sorted[k+1] - values_sorted[k]))
    end

    it "pipeline mode should perform better than non-pipeline mode" do
      benchmark_results = get_benchmark_results
      index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
      index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
      index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size

      puts "95% : In Pipeline but without load : #{percentile(benchmark_results[0], PERCENTILE)} ; In pipeline with load : #{percentile(benchmark_results[1], PERCENTILE)}, Not in pipeline #{percentile(benchmark_results[2], PERCENTILE)}"
      puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
      expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
    end

    it "pipeline mode should perform better than non-pipeline mode with network latency of 10 ms" do
      Toxiproxy[:postgres_proxy].toxic(:latency, latency: 10).apply do
        benchmark_results = get_benchmark_results

        index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
        index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
        index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


        puts "95% : In Pipeline but without load : #{percentile(benchmark_results[0], PERCENTILE)} ; In pipeline with load : #{percentile(benchmark_results[1], PERCENTILE)}, Not in pipeline #{percentile(benchmark_results[2], PERCENTILE)}"
        puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
        expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
      end
    end

    it "pipeline mode should perform better than non-pipeline mode with network latency of 10 ms with 11 queries using load_in_pipeline" do
      Toxiproxy[:postgres_proxy].toxic(:latency, latency: 10).apply do
        benchmark_results = get_benchmark_results_on_steroids
        index_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
        index_with_load_in_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size
        index_non_pipeline_benchmarks_average = benchmark_results[2].sum / benchmark_results[2].size


        puts "95% : In Pipeline but without load : #{percentile(benchmark_results[0], PERCENTILE)} ; In pipeline with load : #{percentile(benchmark_results[1], PERCENTILE)}, Not in pipeline #{percentile(benchmark_results[2], PERCENTILE)}"
        puts "In Pipeline but without load : #{index_pipeline_benchmarks_average} ; In pipeline with load : #{index_with_load_in_pipeline_benchmarks_average}, Not in pipeline #{index_non_pipeline_benchmarks_average}"
        expect(index_with_load_in_pipeline_benchmarks_average).to be < index_non_pipeline_benchmarks_average
      end
    end

    it "pipeline mode should perform better than non-pipeline mode in transaction scenarios" do
      benchmark_results = get_transaction_benchmark_results

      transaction_pipeline_benchmarks_average = benchmark_results[0].sum / benchmark_results[0].size
      transaction_non_pipeline_benchmarks_average = benchmark_results[1].sum / benchmark_results[1].size


      puts "95% : In Pipeline but without load : #{percentile(benchmark_results[0], PERCENTILE)} ; Not in pipeline #{percentile(benchmark_results[1], PERCENTILE)}"
      puts "In Pipeline but without load : #{transaction_pipeline_benchmarks_average} ; Not in pipeline #{transaction_non_pipeline_benchmarks_average}"
      expect(transaction_pipeline_benchmarks_average).to be < transaction_non_pipeline_benchmarks_average
    end

    it "test the working of transaction in pipeline mode" do
      ActiveRecord::Base.transaction do
        blog = Blog.create()
        @tag = Tag.create!(name: "Tag", blog: blog)
      end
      rescue error
        puts "Oops. We tried to do an invalid operation!"
    end

    it "test the working of transaction in non-pipeline mode" do
      ActiveRecord::Base.establish_connection :test_non_pipeline
      ActiveRecord::Base.transaction do
        blog = Blog.create()
        @tag = Tag.create!(name: "Tag", blog: blog)
      end
      rescue error
        puts "Oops. We tried to do an invalid operation!"
      ActiveRecord::Base.establish_connection :test
    end
  end
end