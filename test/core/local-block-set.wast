;; Syntax

(module
  (func (export "syntax")
    (local $y1 i64)
    (local $y2 i32)

    (block (set))
    (block $l (set))
    (block (param) (set))
    (block $l (param) (set))
    (block (result) (set))
    (block $l (result) (set))
    (block (param) (result) (set))
    (block $l (param) (result) (set))

    (block $l (set $y1))
    (block $l (set $y1 $y2))
    (block $l (set $y1 $y1 0 1))
    (block $l (set 0 $y1) (set $y1 $y2))

    (i32.const 1)
    (block $l (param i32) (result i64) (set $y1 $y2) (br $l (i64.const 3)))
    (drop)

    block (set) end
    block $l (set) end
    block (param) (set) end
    block $l (param) (set) end
    block (result) (set) end
    block $l (result) (set) end
    block (param) (result) (set) end
    block $l (param) (result) (set) end

    block $l (set $y1) end
    block $l (set $y1 $y2) end
    block $l (set $y1 $y1 0 1) end
    block $l (set 0 $y1) (set $y1 $y2) end

    (i32.const 1)
    block $l (param i32) (result i64) (set $y1 $y2) (br $l (i64.const 3)) end
    (drop)

    (loop (set))
    (loop $l (set))
    (loop (param) (set))
    (loop $l (param) (set))
    (loop (result) (set))
    (loop $l (result) (set))
    (loop (param) (result) (set))
    (loop $l (param) (result) (set))

    (loop $l (set $y1))
    (loop $l (set $y1 $y2))
    (loop $l (set $y1 $y1 0 1))
    (loop $l (set 0 $y1) (set $y1 $y2))

    (i32.const 1)
    (loop $l (param i32) (result i64) (set $y1 $y2) (i64.extend_i32_u))
    (drop)

    loop (set) end
    loop $l (set) end
    loop (param) (set) end
    loop $l (param) (set) end
    loop (result) (set) end
    loop $l (result) (set) end
    loop (param) (result) (set) end
    loop $l (param) (result) (set) end

    loop $l (set $y1) end
    loop $l (set $y1 $y2) end
    loop $l (set $y1 $y1 0 1) end
    loop $l (set 0 $y1) (set $y1 $y2) end

    (i32.const 1)
    loop $l (param i32) (result i64) (set $y1 $y2) (i64.extend_i32_u) end
    (drop)

    (i32.const 1)
    (if (set) (then))
    (i32.const 1)
    (if $l (set) (then))
    (i32.const 1)
    (if (param) (set) (then))
    (i32.const 1)
    (if $l (param) (set) (then))
    (i32.const 1)
    (if (result) (set) (then))
    (i32.const 1)
    (if $l (result) (set) (then))
    (i32.const 1)
    (if (param) (result) (set) (then))
    (i32.const 1)
    (if $l (param) (result) (set) (then))

    (i32.const 1)
    (if $l (set $y1) (then))
    (i32.const 1)
    (if $l (set $y1 $y2) (then))
    (i32.const 1)
    (if $l (set $y1 $y1 0 1) (then))
    (i32.const 1)
    (if $l (set 0 $y1) (set $y1 $y2) (then))

    (i32.const 1)
    (i32.const 1)
    (if $l (param i32) (result i64) (set $y1 $y2)
      (then (i64.extend_i32_s))
      (else (br $l (i64.const 4)))
    )
    (drop)

    (i32.const 1)
    if (set) else end
    (i32.const 1)
    if $l (set) end
    (i32.const 1)
    if (param) (set) else end
    (i32.const 1)
    if $l (param) (set) end
    (i32.const 1)
    if (result) (set) else end
    (i32.const 1)
    if $l (result) (set) end
    (i32.const 1)
    if (param) (result) (set) else end
    (i32.const 1)
    if $l (param) (result) (set) end

    (i32.const 1)
    if $l (set $y1) else end
    (i32.const 1)
    if $l (set $y1 $y2) end
    (i32.const 1)
    if $l (set $y1 $y1 0 1) else end
    (i32.const 1)
    if $l (set 0 $y1) (set $y1 $y2) else end

    (i32.const 1)
    (i32.const 1)
    if $l (param i32) (result i64) (set $y1 $y2)
      (br $l (i64.const 3))
    else
      (i64.extend_i32_u)
    end
    (drop)
  )
)

(assert_return (invoke "syntax"))


(assert_malformed
  (module quote "(func (block (set) (param)))")
  "unexpected token"
)
(assert_malformed
  (module quote
    "(func"
    "  (local i32)"
    "  (i32.const 0) (i32.const 0)"
    "  (block (set 0) (param i32) (drop))"
    ")"
  )
  "unexpected token"
)

(assert_malformed
  (module quote "(func (block (set) (result)))")
  "unexpected token"
)
(assert_malformed
  (module quote
    "(func (result i32)"
    "  (local i32)"
    "  (i32.const 0)"
    "  (block (set 0) (result i32) (local.get 0))"
    ")"
  )
  "unexpected token"
)
(assert_malformed
  (module quote
    "(func (result i32)"
    "  (local $x i32)"
    "  (block (set $x) (result i32) (local.get 0))"
    ")"
  )
  "unexpected token"
)

(assert_malformed
  (module quote "(func (block (set) $l))")
  "unexpected token"
)


;; Typing

(module
  (type $t (func))
  (func $f)
  (elem declare func $f)

  (func
    (local $x i32)
    (drop (local.get $x))
    (block (set $x))
    (drop (local.get $x))
  )
  (func (param $x i32)
    (drop (local.get $x))
    (block (set $x))
    (drop (local.get $x))
  )

  (func (param $x (ref $t))
    (drop (local.get $x))
    (block (set $x))
    (drop (local.get $x))
  )

  (func
    (local $x (ref $t))
    (local.set $x (ref.func $f))
    (drop (local.get $x))
    (block (set $x))
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (block (set $x)
      (local.set $x (ref.func $f))
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (block (set $x)
      (block (set $x)
        (local.set $x (ref.func $f))
      )
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (block (set $x)
      (local.set $x (ref.func $f))
    )
    (drop (local.get $x))
    (block (set $x)
      (drop (local.get $x))
    )
  )

  (func
    (local $x (ref $t))
    (block $l
      (block (set $x)
        (br $l)
        (drop (local.get $x))
      )
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (block $l
      (block (set $x)
        (i32.const 0)
        (br_table $l $l)
        (drop (local.get $x))
      )
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (block $l
      (block (set $x)
        (unreachable)
        (drop (local.get $x))
      )
      (drop (local.get $x))
    )
  )

  (func
    (local $x i32)
    (drop (local.get $x))
    (loop (set $x))
    (drop (local.get $x))
  )
  (func (param $x i32)
    (drop (local.get $x))
    (loop (set $x))
    (drop (local.get $x))
  )

  (func (param $x (ref $t))
    (drop (local.get $x))
    (loop (set $x))
    (drop (local.get $x))
  )

  (func
    (local $x (ref $t))
    (local.set $x (ref.func $f))
    (drop (local.get $x))
    (loop (set $x))
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (loop (set $x)
      (local.set $x (ref.func $f))
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (loop (set $x)
      (loop (set $x)
        (local.set $x (ref.func $f))
      )
      (drop (local.get $x))
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (loop (set $x)
      (local.set $x (ref.func $f))
    )
    (drop (local.get $x))
    (loop (set $x)
      (drop (local.get $x))
    )
  )

  (func
    (local $x (ref $t))
    (loop $l (set $x)
      (br $l)
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (loop $l (set $x)
      (i32.const 0)
      (br_table $l $l)
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (loop $l (set $x)
      (unreachable)
      (drop (local.get $x))
    )
  )

  (func
    (local $x i32)
    (drop (local.get $x))
    (i32.const 1)
    (if (set $x) (then))
    (drop (local.get $x))
  )
  (func (param $x i32)
    (drop (local.get $x))
    (i32.const 1)
    (if (set $x) (then))
    (drop (local.get $x))
  )

  (func (param $x (ref $t))
    (drop (local.get $x))
    (i32.const 1)
    (if (set $x) (then))
    (drop (local.get $x))
  )

  (func
    (local $x (ref $t))
    (local.set $x (ref.func $f))
    (drop (local.get $x))
    (i32.const 1)
    (if (set $x) (then))
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (i32.const 1)
    (if (set $x)
      (then
        (local.set $x (ref.func $f))
        (drop (local.get $x))
      )
      (else
        (local.set $x (ref.func $f))
        (drop (local.get $x))
      )
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (i32.const 1)
    (if (set $x)
      (then
        (block (set $x)
          (local.set $x (ref.func $f))
        )
        (drop (local.get $x))
      )
      (else
        (block (set $x)
          (local.set $x (ref.func $f))
        )
        (drop (local.get $x))
      )
    )
    (drop (local.get $x))
  )
  (func
    (local $x (ref $t))
    (block (set $x)
      (local.set $x (ref.func $f))
    )
    (drop (local.get $x))
    (i32.const 1)
    (if (set $x)
      (then (drop (local.get $x)))
    )
  )

  (func
    (local $x (ref $t))
    (block $l
      (i32.const 1)
      (if (set $x)
        (then
          (br $l)
          (drop (local.get $x))
        )
        (else
          (br $l)
          (drop (local.get $x))
        )
      )
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (block $l
      (i32.const 1)
      (if (set $x)
        (then
          (i32.const 0)
          (br_table $l $l)
          (drop (local.get $x))
        )
        (else
          (i32.const 0)
          (br_table $l $l)
          (drop (local.get $x))
        )
      )
      (drop (local.get $x))
    )
  )
  (func
    (local $x (ref $t))
    (block $l
      (i32.const 1)
      (if (set $x)
        (then
          (unreachable)
          (drop (local.get $x))
        )
        (else
          (unreachable)
          (drop (local.get $x))
        )
      )
      (drop (local.get $x))
    )
  )

  (elem declare func $pow)
  (type $pow (func (param $x i64) (param $n i32) (result i64)))
  (func $pow (export "pow") (param $x i64) (param $n i32) (result i64)
    (local $y i64)
    (local $recurse (ref $pow))
    (local.set $y
      (if (result i64) (i32.and (local.get $n) (i32.const 1))
        (then (local.get $x)) (else (i64.const 1))
      )
    )
    (i64.mul
      (block (result i64) (set $recurse)
        (local.set $recurse (ref.func $pow))
        (local.get $y)
      )
      (if (result i64) (i32.le_u (local.get $n) (i32.const 1))
        (then (i64.const 1))
        (else
          (call_ref
            (i64.mul (local.get $x) (local.get $x))
            (i32.shr_u (local.get $n) (i32.const 1))
            (local.get $recurse)
          )
        )
      )
    )
  )
)

(assert_return (invoke "pow" (i64.const 17) (i32.const 0)) (i64.const 1))
(assert_return (invoke "pow" (i64.const 19) (i32.const 1)) (i64.const 19))
(assert_return (invoke "pow" (i64.const 11) (i32.const 2)) (i64.const 121))
(assert_return (invoke "pow" (i64.const 13) (i32.const 3)) (i64.const 2197))
(assert_return (invoke "pow" (i64.const 2) (i32.const 4)) (i64.const 16))
(assert_return (invoke "pow" (i64.const 3) (i32.const 5)) (i64.const 243))
(assert_return (invoke "pow" (i64.const 5) (i32.const 6)) (i64.const 15625))
(assert_return (invoke "pow" (i64.const 7) (i32.const 7)) (i64.const 823543))

(assert_invalid
  (module
    (type $t (func))
    (func
      (local $x (ref $t))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (func
      (local $x (ref $t))
      (block
        (local.get $x)
        (drop)
      )
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block (local.set $x (ref.func $f)))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block (set $x)
        (block (local.set $x (ref.func $f)))
      )
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block (set $x))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (loop (set $x))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (if (set $x) (then (local.set $x (ref.func $f))))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)
(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (if (set $x) (then) (else (local.set $x (ref.func $f))))
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block $l (set $x)
        (i32.const 0)
        (br_if $l)
        (local.set $x (ref.func $f))
      )
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block $l (set $x)
        (i32.const 0)
        (br_table 1 1 $l 1)
        (local.set $x (ref.func $f))
      )
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)

(assert_invalid
  (module
    (type $t (func))
    (elem declare func $f)
    (func $f
      (local $x (ref $t))
      (block $l (set $x)
        (i32.const 0)
        (br_table 1 1 $l)
        (local.set $x (ref.func $f))
      )
      (local.get $x)
      (drop)
    )
  )
  "uninitialized local"
)
