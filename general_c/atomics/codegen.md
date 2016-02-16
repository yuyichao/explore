# Codegen of atomic store and load on different archs

|    |`store(relaxed)`|`store(release)`|`store(seq_cst)`|`load(relaxed)`|`load(acquire)`|`load(seq_cst)`|
|----|----------------|----------------|----------------|---------------|---------------|---------------|
|armv7l|`str`|`dmb ish; str`|`dmb ish; str; dmb ish`|`ldr`|`ldr; dmb ish`|`ldr; dmb ish`|
|aarch64|`str`|`stlr`|`stlr`|`ldr`|`ldar`|`ldar`|
|x86_64|`mov`|`mov`|`xchg`|`mov`|`mov`|`mov`|
|i686|`mov`|`mov`|`xchg`|`mov`|`mov`|`mov`|
