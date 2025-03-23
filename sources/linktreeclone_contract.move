module linktreeclone_contract::linktreeclone_contract;

use std::string::String;
use sui::object_table::{Self, ObjectTable as Table};

public struct UserTable has key, store {
  id: UID,
  users: Table<address, User>,
  links: Table<ID, Link>,
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
  links: vector<ID>,
}

public struct Link has key, store {
  id: UID,
  owner: address,
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
const E_UNAUTHORIZED: u64 = 3;
const E_INVALID_LINK: u64 = 4;
const E_LINK_NOT_PUBLIC: u64 = 5;
const E_LINK_NOT_FOUND: u64 = 6;

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
    
    let link_id = object::new(ctx);
    let id_copy = object::uid_to_inner(&link_id);
    
    let link = Link {
        id: link_id,
        owner: sender,
        url,
        title,
        description,
        image_url,
        tags,
        isPublic: is_public,
        platform,
    };
    
    object_table::add(&mut object_table.links, id_copy, link);
    vector::push_back(&mut user.links, id_copy);
}

public fun remove_link(
    object_table: &mut UserTable,
    index: u64,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    let user = object_table::borrow_mut(&mut object_table.users, sender);
    
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    let link_id = vector::swap_remove(&mut user.links, index);
    
    let Link { id, owner: _, url: _, title: _, description: _, image_url: _, tags: _, isPublic: _, platform: _ } = 
        object_table::remove(&mut object_table.links, link_id);
    object::delete(id);
}

// View functions
public fun get_user_profile(object_table: &UserTable, user_addr: address): &User {
    assert!(object_table::contains(&object_table.users, user_addr), E_USER_NOT_FOUND);
    object_table::borrow(&object_table.users, user_addr)
}

public fun get_user_links_ids(object_table: &UserTable, user_addr: address): &vector<ID> {
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

// View functions for Link
public fun get_link_by_id(object_table: &UserTable, link_id: ID): &Link {
    assert!(object_table::contains(&object_table.links, link_id), E_LINK_NOT_FOUND);
    object_table::borrow(&object_table.links, link_id)
}

public fun get_link(object_table: &UserTable, user_addr: address, index: u64): &Link {
    let user = get_user_profile(object_table, user_addr);
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    let link_id = vector::borrow(&user.links, index);
    get_link_by_id(object_table, *link_id)
}

public fun is_link_visible(
    object_table: &UserTable, 
    user_addr: address, 
    index: u64, 
    viewer: address
): bool {
    let user = get_user_profile(object_table, user_addr);
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    let link_id = vector::borrow(&user.links, index);
    let link = get_link_by_id(object_table, *link_id);
    link.isPublic || user_addr == viewer
}

public fun get_public_links(object_table: &UserTable, user_addr: address): vector<u64> {
    let user = get_user_profile(object_table, user_addr);
    let len = vector::length(&user.links);
    let mut public_indices = vector::empty<u64>();
    let mut i = 0;
    while (i < len) {
        let link_id = vector::borrow(&user.links, i);
        let link = get_link_by_id(object_table, *link_id);
        if (link.isPublic) {
            vector::push_back(&mut public_indices, i);
        };
        i = i + 1;
    };
    public_indices
}

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

public fun get_link_owner(link: &Link): address {
    link.owner
}

// Add init function
fun init(ctx: &mut TxContext) {
    let user_table = UserTable {
        id: object::new(ctx),
        users: object_table::new(ctx),
        links: object_table::new(ctx),
    };
    transfer::share_object(user_table);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}

// Add after other functions
public fun delete_user(
    object_table: &mut UserTable,
    ctx: &mut TxContext,
) {
    let sender = tx_context::sender(ctx);
    assert!(object_table::contains(&object_table.users, sender), E_USER_NOT_FOUND);
    
    let User { id, display_name: _, bio: _, avatar_url: _, mut links } = 
        object_table::remove(&mut object_table.users, sender);
        
    // 删除所有链接
    let len = vector::length(&links);
    let mut i = 0;
    while (i < len) {
        let link_id = vector::pop_back(&mut links);
        if (object_table::contains(&object_table.links, link_id)) {
            let Link { id: link_uid, owner: _, url: _, title: _, description: _, image_url: _, tags: _, isPublic: _, platform: _ } = 
                object_table::remove(&mut object_table.links, link_id);
            object::delete(link_uid);
        };
        i = i + 1;
    };
    
    vector::destroy_empty(links);
    object::delete(id);
}

// Add getter function for checking user existence
public fun contains_user(object_table: &UserTable, user_addr: address): bool {
    object_table::contains(&object_table.users, user_addr)
}

// Add update link function
public fun update_link(
    object_table: &mut UserTable,
    index: u64,
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
    let user = object_table::borrow(&object_table.users, sender);
    assert!(index < vector::length(&user.links), E_INVALID_LINK);
    
    let link_id = vector::borrow(&user.links, index);
    let link = object_table::borrow_mut(&mut object_table.links, *link_id);
    assert!(link.owner == sender, E_UNAUTHORIZED);
    
    link.url = url;
    link.title = title;
    link.description = description;
    link.image_url = image_url;
    link.tags = tags;
    link.isPublic = is_public;
    link.platform = platform;
}

