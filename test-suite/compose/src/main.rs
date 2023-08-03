use std::env::args;
use std::io::{self, Write};

use anyhow::{bail, Context};
use wasm_compose::graph::{self, CompositionGraph};

fn main() -> anyhow::Result<()> {
    let mut args = args();
    let exe = args.next();
    let (interface, runner, test) = match (args.next(), args.next(), args.next(), args.next()) {
        (Some(interface), Some(runner), Some(test), None) => (interface, runner, test),
        _ => {
            let exe = exe.as_deref().unwrap_or(env!("CARGO_BIN_NAME"));
            bail!(
                r#"takes exactly three arguments
Usage: {exe} INTERFACE RUNNER TEST"#
            )
        }
    };

    let mut g = CompositionGraph::new();

    let test = graph::Component::from_file("$test", &test)
        .with_context(|| format!("failed to parse `{test}` component"))?;
    let runner = graph::Component::from_file("$runner", &runner)
        .with_context(|| format!("failed to parse `{runner}` component"))?;

    let test_export = test
        .exports()
        .find_map(|(id, name, _, _)| name.eq(&interface).then_some(id))
        .with_context(|| format!("could not find `{interface}` export in test component"))?;
    let runner_import = runner
        .imports()
        .find_map(|(id, name, _)| name.eq(&interface).then_some(id))
        .with_context(|| format!("could not find `{interface}` import in runner component"))?;

    let test = g
        .add_component(test)
        .context("failed to add test component to the graph")?;
    let runner = g
        .add_component(runner)
        .context("failed to add runner component to the graph")?;

    let runner = g
        .instantiate(runner)
        .context("failed to instantiate runner component")?;
    let test = g
        .instantiate(test)
        .context("failed to instantiate test component")?;

    g.connect(test, Some(test_export), runner, runner_import)
        .with_context(|| {
            format!("failed to connect `{interface}` from test component to runner component")
        })?;

    let wasm = g
        .encode(graph::EncodeOptions {
            define_components: true,
            export: Some(runner),
            validate: true,
        })
        .context("failed to encode graph")?;
    io::stdout()
        .write_all(&wasm)
        .context("failed to write component to stdout")
}
