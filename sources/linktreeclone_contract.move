module linktreeclone_contract::linktreeclone_contract;

use std::string::String;
use sui::table;

public struct UserTable has key, store {
  id: UID,
  users: table::Table<address, User>,
}

public struct UserStyleConfig has copy, store, drop {
  theme: String,
  primary_color: String,
  background_type: String,
  background_color: String,
  background_image: String,
  font_family: String,
}

public struct LinkStyleConfig has copy, store, drop {
  bg_color: String,
  order: u64,
  is_gradient: bool,
  gradient_from: String,
  gradient_to: String,
  style: String,
  thumbnail_url: String,
}

public struct ConfigKey<phantom Config> has copy, store, drop {}

public struct User has store {
  id: UID,
  display_name: String,
  bio: String,
  avatar_url: String,
  links: vector<Link>,
}

public struct Link has store, drop {
  url: String,
  title: String,
  description: String,
  image_url: String,
  tags: vector<String>,
  isPublic: bool,
  platform: String,
}


