module linktreeclone_contract::linktreeclone_contract;

use std::string::String;
use sui::object_table::{Self, ObjectTable as Table};

public struct UserTable has key, store {
  id: UID,
  users: Table<address, User>,
}

#[allow(unused_field)]
public struct UserStyleConfig has copy, store, drop {
  theme: String,
  primary_color: String,
  background_type: String,
  background_color: String,
  background_image: String,
  font_family: String,
}

#[allow(unused_field)]
public struct LinkStyleConfig has copy, store, drop {
  bg_color: String,
  order: u64,
  is_gradient: bool,
  gradient_from: String,
  gradient_to: String,
  style: String,
  thumbnail_url: String,
}

#[allow(unused_field)]
public struct ConfigKey<phantom Config> has copy, store, drop {}

public struct User has key, store {
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

// Error codes
const E_USER_NOT_FOUND: u64 = 1;
const E_USER_ALREADY_EXISTS: u64 = 2;
const E_INVALID_LINK: u64 = 4;

// Core functions for user management
public fun create_user(
    object_table: &mut UserTable,
    display_name: String,
    bio: String,
    avatar_url: String,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    assert!(!object_table::contains(&object_table.users, sender), E_USER_ALREADY_EXISTS);

    let user = User {
        id: object::new(ctx),
        display_name,
        bio,
        avatar_url,
        links: vector::empty(),
    };
    
    object_table::add(&mut object_table.users, sender, user);
}

public fun update_user_profile(
    object_table: &mut UserTable,
    display_name: String,
    bio: String,
    avatar_url: String,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    let user = object_table::borrow_mut(&mut object_table.users, sender);
    
    user.display_name = display_name;
    user.bio = bio;
    user.avatar_url = avatar_url;
}

public fun add_link(
    object_table: &mut UserTable,
    url: String,
    title: String,
    description: String,
    image_url: String,
    tags: vector<String>,
    is_public: bool,
    platform: String,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    let user = object_table::borrow_mut(&mut object_table.users, sender);
    
    let link = Link {
        url,
        title,
        description,
        image_url,
        tags,
        isPublic: is_public,
        platform,
    };
    
    vector::push_back(&mut user.links, link);
}

public fun remove_link(
    object_table: &mut UserTable,
    index: u64,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    let user = object_table::borrow_mut(&mut object_table.users, sender);
    
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    vector::remove(&mut user.links, index);
}

// View functions
public fun get_user_profile(object_table: &UserTable, user_addr: address): &User {
    assert!(object_table::contains(&object_table.users, user_addr), E_USER_NOT_FOUND);
    object_table::borrow(&object_table.users, user_addr)
}

public fun get_user_links(object_table: &UserTable, user_addr: address): &vector<Link> {
    let user = get_user_profile(object_table, user_addr);
    &user.links
}

// View functions for User
public fun get_display_name(user: &User): &String {
    &user.display_name
}

public fun get_bio(user: &User): &String {
    &user.bio
}

public fun get_avatar_url(user: &User): &String {
    &user.avatar_url
}

public fun get_links_count(user: &User): u64 {
    vector::length(&user.links)
}

public fun get_link_at(user: &User, index: u64): &Link {
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    vector::borrow(&user.links, index)
}

// View functions for Link
public fun get_link_url(link: &Link): &String {
    &link.url
}

public fun get_link_title(link: &Link): &String {
    &link.title
}

public fun get_link_description(link: &Link): &String {
    &link.description
}

public fun get_link_image_url(link: &Link): &String {
    &link.image_url
}

public fun get_link_tags(link: &Link): &vector<String> {
    &link.tags
}

public fun is_link_public(link: &Link): bool {
    link.isPublic
}

public fun get_link_platform(link: &Link): &String {
    &link.platform
}

// Add init function
fun init(ctx: &mut TxContext) {
    let user_table = UserTable {
        id: object::new(ctx),
        users: object_table::new(ctx),
    };
    transfer::share_object(user_table);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}


