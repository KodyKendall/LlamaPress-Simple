Rails.application.configure do
  config.llama_bot_rails.websocket_url      = ENV.fetch("LLAMABOT_WEBSOCKET_URL", "ws://localhost:8000/ws")
  config.llama_bot_rails.llamabot_api_url   = ENV.fetch("LLAMABOT_API_URL", "http://localhost:8000")
  config.llama_bot_rails.enable_console_tool = !Rails.env.production?

  # ------------------------------------------------------------------------
  # Custom State Builder
  # ------------------------------------------------------------------------
  # The gem uses `LlamaBotRails::AgentStateBuilder` by default.
  # Uncomment this line to use the builder in app/llama_bot/
  #
  config.llama_bot_rails.state_builder_class = "AgentStateBuilder"

  # ------------------------------------------------------------------------
  # Custom User Resolver
  # ------------------------------------------------------------------------
  # The gem uses `warden.user` by default.
  # Uncomment this line to use a custom user resolver in app/llama_bot/
  # Example: if you don't use Devise, uncomment and tweak:
  # 
  # LlamaBotRails.user_resolver = ->(user_id) do
  #   # Try to find a User model, fallback to nil if not found
  #   if defined?(Devise)
  #     default_scope = Devise.default_scope # e.g., :user
  #     user_class = Devise.mappings[default_scope].to
  #     user_class.find_by(id: user_id)
  #   else
  #     Rails.logger.warn("[[LlamaBot]] Implement a user_resolver! in your app to resolve the user from the user_id.")
  #     nil
  #   end
  # end

  # ------------------------------------------------------------------------
  # Custom Current User Resolver
  # ------------------------------------------------------------------------
  # Default (Devise / Warden); returns nil if Devise absent
  # 
  # LlamaBotRails.current_user_resolver = ->(env) do
  #   # Try to find a User model, fallback to nil if not found
  #   if defined?(Devise)
  #     env['warden']&.user
  #   else
  #     Rails.logger.warn("[[LlamaBot]] Implement a current_user_resolver! in your app to resolve the current user from the environment.")
  #     nil
  #   end
  # end

  # ------------------------------------------------------------------------
  # Custom Sign-in Method
  # ------------------------------------------------------------------------
  # Lambda that receives Rack env and user_id, and sets the user in the warden session
  # Default sign-in method is configured for Devise with Warden.
  # 
  # LlamaBotRails.sign_in_method = ->(env, user) do
  #   env['warden']&.set_user(user)
  # end

  # ------------------------------------------------------------------------
  # Alternative Examples for Non-Devise Apps
  # ------------------------------------------------------------------------
  # Example: if you don't use Devise, uncomment and tweak:
  # 
  # LlamaBotRails.user_resolver = ->(user_id) do
  #   # Rack session example
  #   if user_id
  #     User.find_by(id: user_id)
  #   end
  # end
  #
  # LlamaBotRails.current_user_resolver = ->(env) do
  #   # Rack session example
  #   if id = env['rack.session'][:user_id]
  #     User.find_by(id: id)
  #   end
  # end
  #
  # LlamaBotRails.sign_in_method = ->(env, user) do
  #   # Set user in rack session
  #   env['rack.session'][:user_id] = user&.id
  # end
end
