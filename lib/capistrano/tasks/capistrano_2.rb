module Capistrano
  Configuration.instance(true).load do
    def _cset(name, *args, &block)
      set(name, *args, &block) if !exists?(name)
    end

    Capistrano::S3::Defaults.populate(self, :_cset)

    # Deployment recipes
    namespace :deploy do
      namespace :s3 do
        desc "Empties bucket of all files. Caution when using this command, as it cannot be undone!"
        task :empty do
          S3::Publisher.clear!(s3_endpoint, access_key_id, secret_access_key, bucket)
        end

        desc "Upload files to the bucket in the current state"
        task :upload_files do
          extra_options = { :write => bucket_write_options, :redirect => redirect_options }
          S3::Publisher.publish!(s3_endpoint, access_key_id, secret_access_key,
                             bucket, deployment_path, desination_path, extra_options)
        end
      end

      task :update do
        s3.upload_files
      end

      task :restart do; end
    end
  end
end
