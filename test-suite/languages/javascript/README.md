# JavaScript

JavaScript can be componentized using `jco`.

```sh
npm install @bytecodealliance/jco
npm install @bytecodealliance/componentize-js
npx jco componentize --wit ../../test-cases/wit/trivial.wit --world-name trivial-test ./trivial.js  -o trivial.js.wasm
```