# encoding: utf-8

RailsAdmin.class_exec do
  authenticate_with   { authenticate_employee! }
  current_user_method { current_employee }

  # authorize_with :cancan

  config do |config|
    config.excluded_models << 'AbstractUser'
  end
end

