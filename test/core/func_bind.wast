(module
  (type $unop (func (param i32) (result i32)))

  (elem func $add)
  (func $add (param i32 i32) (result i32) (i32.add (local.get 0) (local.get 1)))

  (func $mk-adder (param $i i32) (result (ref $unop))
    (func.bind (type $unop) (local.get $i) (ref.func $add))
  )

  (global $f (mut (ref null $unop)) (ref.null))

  (func (export "make") (param $i i32)
    (global.set $f (call $mk-adder (local.get $i)))
  )

  (func (export "call") (param $j i32) (result i32)
    (call_ref (local.get $j) (global.get $f))
  )
)

(assert_trap (invoke "call" (i32.const 0)) "null function")

(assert_return (invoke "make" (i32.const 3)))
(assert_return (invoke "call" (i32.const 2)) (i32.const 5))
(assert_return (invoke "call" (i32.const 10)) (i32.const 13))

(assert_return (invoke "make" (i32.const 0)))
(assert_return (invoke "call" (i32.const 10)) (i32.const 10))

(assert_return (invoke "make" (i32.const -3)))
(assert_return (invoke "call" (i32.const 10)) (i32.const 7))
