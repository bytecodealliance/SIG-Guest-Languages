cargo_component_bindings::generate!();

struct Component;

use bindings::exports::guest_lang::tests::trivial_api::TrivialApi;

impl TrivialApi for Component {
    fn foo() -> u32 {
        42
    }
}
