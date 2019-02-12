# Typed Function References for WebAssembly

## Introduction

This proposal adds function references that are typed and can be called directly. Unlike `funcref` and the existing `call_indirect` instruction, typed function references need not be stored into a table to be called (though they can), they cannot be null, and a call through them does not require any runtime check. A typed function reference can be formed from any function index.

The proposal has instructions for producing and consuming (calling) function references.

Typed references have no canonical default value, because they cannot be null. To enable storing them in locals, which so far depend on default values for initialisation, the proposal also introduces a new instruction `let` for block-scoped locals whose initialisation values are taken from the operand stack.

In addition to the above, we could also decide to include an instruction for forming a *closure* from a function reference, which takes a prefix of the function's arguments and returns a new function reference with those parameters bound. (Hence, conceptually, all function references would be closures of 0 or more parameters.)

Note: In a Wasm engine, function references (whether first-class or as table entries) are already a form of closure since they must close over a specific module instance (its globals, tables, memory, etc) while their code is shared across multiple instances of the same module. It is hence expected that the ability to form language-level closures is not an observable extra cost.


### Motivation

* Enable efficient indirect function calls without runtime checks

* Represent first-class function pointers without the need for tables

* Easier and more efficient exchange of function references between modules and with host environment

* Optionally, support for safe closures

* Separate independently useful features from [GC proposal](https://github.com/WebAssembly/gc/blob/master/proposals/gc/Overview.md)


### Summary

* This proposal is based on the [reference types proposal](https://github.com/WebAssembly/reference-types))

* Add a new form of non-nullable *typed reference type* `ref $t`, where `$t` is a type index; can be used as both a value type or an element type for tables

* Add an instruction `call_ref` for calling a function through a `ref $t`

* Add an instruction `ref.func $f` for creating a function reference

* Optionally add an instruction `func.bind` to create a closure

* Add a block instruction `let (local t*) ... end` for introducing locals with block scope, in order to handle reference types without default initialisation values


## Language

Based on [reference types proposal](https://github.com/WebAssembly/reference-types/blob/master/proposals/reference-types/Overview.md), which introduces type `anyref` and `funcref`.


### Types

#### Value Types

* `ref <typeidx>` is a new reference type
  - `reftype ::= ... | ref <typeidx>`
  - `ref $t ok` iff `$t` is defined in the context

Question: Include optref as well?


#### Subtyping

* Any function reference type is a subtype of `funcref`
  - `ref $t <: funcref`
     - iff `$t = <functype>`


#### Defaultability

* Any numeric value type is defaultable (to 0)

* A reference value type is defaultable (to `null`) if it is not of the form `ref $t`

* Function-level locals must have a type that is defaultable.

* Table definitions with non-zero minimum size must have an element type that is defaultable. (Imports are not affected.)


### Instructions

#### Functions

* `ref.func` creates a function reference from a function index
  - `ref.func $f : [] -> [(ref $t)]`
     - iff `$f : $t`
  - this is a *constant instruction*

* `call_ref` calls a function through a reference
  - `call_ref : [t1* (ref $t)] -> [t2*]`
     - iff `$t = [t1*] -> [t2*]`

* Optional extension: `func.bind` creates or extends a closure by binding one or several parameters
  - `func.bind $t : [t1^n (ref $t)] -> [(ref $t')]`
    - iff `$t = [t1^n t1'*] -> [t2*]`
    - and `$t' = [t1'*] -> [t2*]`

Questions:
- The naming conventions for these instructions seem rather incoherent, are there better ones?
- The requirement to provide type `$t'` instead of just a number is a hack to side-step the issue of expressing an anonymous function type. Should we try better?


#### Local Bindings

* `let <blocktype> (local <valtype>)* <instr>* end` locally binds operands to variables
  - `let bt (local t)* instr* end : [t* t1*] -> [t2*]`
    - iff `bt = [t1*] -> [t2*]`
    - and `instr* : bt` under a context with `locals` extended by `t*` and `labels` extended by `[t2*]`


## Binary Format

TODO.


## JS API

Based on the JS type reflection proposal.

### Type Representation

* A `ValueType` can be described by an object of the form `{ref: DefType}` and `{optref: DefType}`
  - `type ValueType = ... | {ref: DefType} | {optref: DefType}`


### Value Conversions

#### Reference Types

In addition to the rules for basic reference types:

* Any function that is an instance of `WebAssembly.Function` with type `<functype>` is allowed as `ref <functype>`.


### Constructors

#### `Global`

* `TypeError` is produced if the `Global` constructor is invoked without a value argument but a type that is not defaultable.

#### `Table`

* The `Table` constructor gets an additional optional argument `init` that is used to initialise the table slots. It defaults to `null`. A `TypeError` is produced if the argument is omitted and the table's element type is not defaultable.
