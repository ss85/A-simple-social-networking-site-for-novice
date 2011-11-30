# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Bookie_session',
  :secret      => 'b1a981412ad4d095009181a46967df2c49515482ae78dab629f4cd3a9a5faf4488bc759bca4f2b7764f5263cd499ba8d0d4daa683770271d37c67c20e485a761'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
