#[test_only]
module linktreeclone_contract::linktreeclone_contract_tests {
    use sui::test_scenario;
    use linktreeclone_contract::linktreeclone_contract::{Self, UserTable};
    use std::string;

    #[test]
    fun test_create_user() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize the contract
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Create user
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            assert!(linktreeclone_contract::get_display_name(user) == &string::utf8(b"Test User"), 1);
            assert!(linktreeclone_contract::get_bio(user) == &string::utf8(b"Bio"), 2);
            assert!(linktreeclone_contract::get_avatar_url(user) == &string::utf8(b"avatar.jpg"), 3);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_add_link() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize the contract
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Create user and add link
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            assert!(linktreeclone_contract::get_links_count(user) == 1, 1);
            
            // Verify link data
            let link = linktreeclone_contract::get_link(table_mut, owner, 0);
            assert!(linktreeclone_contract::get_link_url(link) == &string::utf8(b"https://example.com"), 2);
            assert!(linktreeclone_contract::get_link_owner(link) == owner, 3);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_user_getters() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            
            // Test user getters
            assert!(linktreeclone_contract::get_display_name(user) == &string::utf8(b"Test User"), 1);
            assert!(linktreeclone_contract::get_bio(user) == &string::utf8(b"Bio"), 2);
            assert!(linktreeclone_contract::get_avatar_url(user) == &string::utf8(b"avatar.jpg"), 3);
            assert!(linktreeclone_contract::get_links_count(user) == 0, 4);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_link_getters() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user with link
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            assert!(linktreeclone_contract::get_links_count(user) == 1, 1);
            
            let link = linktreeclone_contract::get_link(table_mut, owner, 0);
            assert!(linktreeclone_contract::get_link_url(link) == &string::utf8(b"https://example.com"), 2);
            assert!(linktreeclone_contract::get_link_title(link) == &string::utf8(b"Example"), 3);
            assert!(linktreeclone_contract::get_link_description(link) == &string::utf8(b"Description"), 4);
            assert!(linktreeclone_contract::get_link_image_url(link) == &string::utf8(b"image.jpg"), 5);
            assert!(linktreeclone_contract::is_link_public(link) == true, 6);
            assert!(linktreeclone_contract::get_link_platform(link) == &string::utf8(b"website"), 7);
            assert!(linktreeclone_contract::get_link_owner(link) == owner, 8);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_delete_user() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize the contract
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Create user
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );

            // Verify user exists
            assert!(linktreeclone_contract::contains_user(table_mut, owner), 1);

            test_scenario::return_shared(table);
        };

        // Delete user
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::delete_user(
                table_mut,
                test_scenario::ctx(scenario),
            );

            // Verify user is deleted
            assert!(!linktreeclone_contract::contains_user(table_mut, owner), 2);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_delete_nonexistent_user() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize the contract
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Try to delete non-existent user
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::delete_user(
                table_mut,
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_update_link() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize the contract
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Create user and add link
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(table);
        };

        // Update link
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::update_link(
                table_mut,
                0,
                string::utf8(b"https://updated.com"),
                string::utf8(b"Updated Title"),
                string::utf8(b"Updated Description"),
                string::utf8(b"updated.jpg"),
                vector[string::utf8(b"tag2")],
                false,
                string::utf8(b"social"),
                test_scenario::ctx(scenario),
            );

            // Verify link is updated
            let link = linktreeclone_contract::get_link(table_mut, owner, 0);
            assert!(linktreeclone_contract::get_link_url(link) == &string::utf8(b"https://updated.com"), 1);
            assert!(linktreeclone_contract::get_link_title(link) == &string::utf8(b"Updated Title"), 2);
            assert!(linktreeclone_contract::get_link_description(link) == &string::utf8(b"Updated Description"), 3);
            assert!(linktreeclone_contract::get_link_image_url(link) == &string::utf8(b"updated.jpg"), 4);
            assert!(linktreeclone_contract::is_link_public(link) == false, 5);
            assert!(linktreeclone_contract::get_link_platform(link) == &string::utf8(b"social"), 6);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    fun test_update_invalid_link() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            // Try to update non-existent link
            linktreeclone_contract::update_link(
                table_mut,
                0,
                string::utf8(b"https://updated.com"),
                string::utf8(b"Updated Title"),
                string::utf8(b"Updated Description"),
                string::utf8(b"updated.jpg"),
                vector[string::utf8(b"tag2")],
                false,
                string::utf8(b"social"),
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_link_visibility() {
        let owner = @0xA;
        let viewer = @0xB;
        let admin = @0xC;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        // Create user and add links
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            // Create user
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            // Add public link
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://public.com"),
                string::utf8(b"Public Link"),
                string::utf8(b"Public Description"),
                string::utf8(b"public.jpg"),
                vector[string::utf8(b"public")],
                true,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );

            // Add private link
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://private.com"),
                string::utf8(b"Private Link"),
                string::utf8(b"Private Description"),
                string::utf8(b"private.jpg"),
                vector[string::utf8(b"private")],
                false,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );

            test_scenario::return_shared(table);
        };

        // Test visibility as owner
        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;

            // Verify owner can see both links
            assert!(linktreeclone_contract::is_link_visible(table_mut, owner, 0, owner), 1);
            assert!(linktreeclone_contract::is_link_visible(table_mut, owner, 1, owner), 2);

            // Verify other user can only see public link
            assert!(linktreeclone_contract::is_link_visible(table_mut, owner, 0, viewer), 3);
            assert!(!linktreeclone_contract::is_link_visible(table_mut, owner, 1, viewer), 4);

            test_scenario::return_shared(table);
        };

        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_user_id() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            let user_id = linktreeclone_contract::get_user_id(user);
            
            // 验证用户 ID 可以被获取
            assert!(linktreeclone_contract::get_user_id_by_address(table_mut, owner) == user_id, 1);
            
            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }

    #[test]
    fun test_link_with_user_id() {
        let owner = @0xA;
        let admin = @0xB;
        let mut scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        
        // Initialize and create user with link
        test_scenario::next_tx(scenario, owner);
        {
            linktreeclone_contract::init_for_testing(test_scenario::ctx(scenario));
        };

        test_scenario::next_tx(scenario, owner);
        {
            let mut table = test_scenario::take_shared<UserTable>(scenario);
            let table_mut = &mut table;
            
            linktreeclone_contract::create_user(
                table_mut,
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
                test_scenario::ctx(scenario),
            );
            
            let user_id = linktreeclone_contract::get_user_id_by_address(table_mut, owner);
            
            linktreeclone_contract::add_link(
                table_mut,
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
                test_scenario::ctx(scenario),
            );
            
            // 确保用户 ID 可以用于获取链接
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            assert!(linktreeclone_contract::get_links_count(user) == 1, 1);
            
            let link = linktreeclone_contract::get_link(table_mut, owner, 0);
            assert!(linktreeclone_contract::get_link_url(link) == &string::utf8(b"https://example.com"), 2);
            
            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }
} 
