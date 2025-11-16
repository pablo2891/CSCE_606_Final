# if Rails.env.development?
#   begin
#     ActionMailer::Base.singleton_class.class_eval do
#       unless method_defined?(:preview_path=) || respond_to?(:preview_path=)
#         define_method(:preview_path=) do |path|
#           self.preview_paths = Array(path)
#         end
#       end

#       unless method_defined?(:preview_path) || respond_to?(:preview_path)
#         define_method(:preview_path) do
#           Array(self.preview_paths).first
#         end
#       end
#     end
#   rescue => e
#     Rails.logger&.warn("action_mailer_preview_compat initializer failed: #{e.class}: #{e.message}")
#   end
# end
