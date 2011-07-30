# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_lonelyplanet_session',
  :secret      => '3243a2235bb7fd18e98b6168e355d8054e3d77050f966900c89ce8be6b921076a1fd8310a3a03bca7a920d07f406689c87370cdd7dc94d306fcca53f57f800bf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
