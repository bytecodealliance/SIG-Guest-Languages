cargo_component_bindings::generate!();

struct Component;

impl bindings::TrivialRunner for Component {
    fn run() -> bool {
        use bindings::guest_lang::tests::trivial_api::*;
        assert_eq!(foo(), 42);
        assert_eq!(foo(), 42);
        assert_eq!(foo(), 42);
        true
    }
}
