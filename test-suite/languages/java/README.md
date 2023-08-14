# Java

```sh
javac -cp <teavm-interop-jar> -d <outdir>/target/classes wit/exports/guest-lang/tests/TestImpl.java Main.java

java -jar <teavm-cli-jar>
    -p <outdir>/target/classes
    -d <outdir>/target/generated/wasm/teavm-wasm
    -t wasm -g -O 1
    --preserve-class wit/exports/guest-lang/tests/TestImpl.java
    --preserve-class Main.java
    Main

# result target/generated/wasm/teavm-wasm/classes.wasm

# TODO run wit-component
```