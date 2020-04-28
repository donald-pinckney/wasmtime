(module
    (func $handler (param $k i64) (param $unused_arg i64)
        local.get $k
        i64.const 200
        restore)
    (func $main (export "main") (result i64)
        i64.const 1234
        control $handler
        i64.const 100
        i64.add))