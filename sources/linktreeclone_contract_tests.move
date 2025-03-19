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
                test_scenario::ctx(scenario),
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
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
                test_scenario::ctx(scenario),
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
            );
            
            linktreeclone_contract::add_link(
                table_mut,
                test_scenario::ctx(scenario),
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
            );
            
            let links = linktreeclone_contract::get_user_links(table_mut, owner);
            assert!(vector::length(links) == 1, 1);

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
                test_scenario::ctx(scenario),
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
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
                test_scenario::ctx(scenario),
                string::utf8(b"Test User"),
                string::utf8(b"Bio"),
                string::utf8(b"avatar.jpg"),
            );
            
            linktreeclone_contract::add_link(
                table_mut,
                test_scenario::ctx(scenario),
                string::utf8(b"https://example.com"),
                string::utf8(b"Example"),
                string::utf8(b"Description"),
                string::utf8(b"image.jpg"),
                vector[string::utf8(b"tag1")],
                true,
                string::utf8(b"website"),
            );
            
            let user = linktreeclone_contract::get_user_profile(table_mut, owner);
            assert!(linktreeclone_contract::get_links_count(user) == 1, 1);
            
            let link = linktreeclone_contract::get_link_at(user, 0);
            assert!(linktreeclone_contract::get_link_url(link) == &string::utf8(b"https://example.com"), 2);
            assert!(linktreeclone_contract::get_link_title(link) == &string::utf8(b"Example"), 3);
            assert!(linktreeclone_contract::get_link_description(link) == &string::utf8(b"Description"), 4);
            assert!(linktreeclone_contract::get_link_image_url(link) == &string::utf8(b"image.jpg"), 5);
            assert!(linktreeclone_contract::is_link_public(link) == true, 6);
            assert!(linktreeclone_contract::get_link_platform(link) == &string::utf8(b"website"), 7);

            test_scenario::return_shared(table);
        };
        
        test_scenario::end(scenario_val);
    }
} 
