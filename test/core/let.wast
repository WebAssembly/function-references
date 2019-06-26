(module
  ;; Auxiliary
  (func $dummy)
  (func $consume (param i32))
  (func $produce (result i32) (i32.const 7))

  (func (export "syntax") (param $x1 i32) (param $x2 i64)
    (local $y1 i64)
    (local $y2 i32)
    (local.set $y2 (i32.const 5))

    (let)
    (let $l)
    (let (local))
    (let $l (local))

    (let (call $dummy) (call $consume (local.get $x1)))
    (let $l (call $dummy) (call $consume (local.get $y2)))
    (let (local) (call $dummy) (call $consume (local.get $y2)))
    (let $l (local) (call $dummy) (call $consume (local.get $x1)))

    (let (call $dummy) (call $dummy) (br 0))
    (let $l (call $dummy) (call $dummy) (br $l))
    (let (local) (call $dummy) (call $dummy) (br 0))
    (let $l (local) (call $dummy) (call $dummy) (br $l))

    (let (result i32) (call $dummy) (call $produce) (call $dummy))
    (drop)
    (let $l (result i32) (call $dummy) (call $produce) (call $dummy))
    (drop)
    (let (result i32) (local) (call $dummy) (call $produce) (call $dummy))
    (drop)
    (let $l (result i32) (local) (call $dummy) (call $produce) (call $dummy))
    (drop)

    (i32.const 1)
    (let (local i32) (call $dummy) (call $consume (local.get 0)))
    (i32.const 2)
    (let $l (local i32) (call $dummy) (call $consume (local.get 0)))
    (i32.const 3)
    (let (local i32) (call $dummy) (call $consume (local.get 0)))
    (i32.const 4)
    (let $l (local i32) (call $dummy) (call $consume (local.get 0)))

    (i32.const 1) (f32.const 2) (i32.const 3) (i64.const 4)
    (let (local i32 f32) (local) (local $z i32) (local i64)
      (call $consume (local.get 0))
      (call $consume (local.get 2))  ;; $z
      (call $consume (local.get 4))  ;; $x1
      (call $consume (local.get 7))  ;; $y2
      (call $consume (local.get $z))
      (call $consume (local.get $x1))
      (call $consume (local.get $y2))
    )

    (f32.const 1) (i32.const 2) (i64.const 3) (i32.const 4)
    (let (result i32) (local $z1 f32) (local $z2 i32) (local) (local i64 i32)
      (call $produce)
      (call $consume (local.get 1))  ;; $z2
      (call $consume (local.get 3))
      (call $consume (local.get 4))  ;; $x1
      (call $consume (local.get 7))  ;; $y2
      (call $consume (local.get $z2))
      (call $consume (local.get $x1))
      (call $consume (local.get $y2))
    )
    (drop)
  )

  (func $pow (export "pow") (param $x i64) (param $n i32) (result i64)
    (local $y i64)
    (local.set $y 
      (if (result i64) (i32.and (local.get $n) (i32.const 1))
        (then (local.get $x)) (else (i64.const 1))
      )
    )
    (i64.mul
      (local.get $y)
      (if (result i64) (i32.le_u (local.get $n) (i32.const 1))
        (then (i64.const 1))
        (else
          (call $pow
            (i64.mul (local.get $x) (local.get $x))
            (i32.shr_u (local.get $n) (i32.const 1))
          )
        )
      )
    )
  )

  (func (export "semantics-idx") (param i64 i64) (result i64)
    (local i64 i64)
    (local.set 2 (i64.const 5))
    (local.set 3 (i64.const 7))

    (i64.const 11) (i64.const 13)
    (let (result i64) (local i64 i64)
      (i64.const 17) (i64.const 19)
      (let (result i64) (local i64 i64)
        (i64.const 0)
        (i64.add (call $pow (local.get 0) (i32.const 0)))  ;; 17^0 =      1
        (i64.add (call $pow (local.get 1) (i32.const 1)))  ;; 19^1 =     19
        (i64.add (call $pow (local.get 2) (i32.const 2)))  ;; 11^2 =    121
        (i64.add (call $pow (local.get 3) (i32.const 3)))  ;; 13^3 =   2197
        (i64.add (call $pow (local.get 4) (i32.const 4)))  ;;  2^4 =     16
        (i64.add (call $pow (local.get 5) (i32.const 5)))  ;;  3^5 =    243
        (i64.add (call $pow (local.get 6) (i32.const 6)))  ;;  5^6 =  15625
        (i64.add (call $pow (local.get 7) (i32.const 7)))  ;;  7^7 = 823543
      )
    )
  )

  (func (export "semantics-sym") (param $x1 i64) (param $x2 i64) (result i64)
    (local $y1 i64)
    (local $y2 i64)
    (local.set $y1 (i64.const 5))
    (local.set $y2 (i64.const 7))

    (i64.const 11) (i64.const 13)
    (let (result i64) (local $z1 i64) (local $z2 i64)
      (i64.const 17) (i64.const 19)
      (let (result i64) (local $u1 i64) (local $u2 i64)
        (i64.const 0)
        (i64.add (call $pow (local.get $u1) (i32.const 0)))  ;; 17^0 =      1
        (i64.add (call $pow (local.get $u2) (i32.const 1)))  ;; 19^1 =     19
        (i64.add (call $pow (local.get $z1) (i32.const 2)))  ;; 11^2 =    121
        (i64.add (call $pow (local.get $z2) (i32.const 3)))  ;; 13^3 =   2197
        (i64.add (call $pow (local.get $x1) (i32.const 4)))  ;;  2^4 =     16
        (i64.add (call $pow (local.get $x2) (i32.const 5)))  ;;  3^5 =    243
        (i64.add (call $pow (local.get $y1) (i32.const 6)))  ;;  5^6 =  15625
        (i64.add (call $pow (local.get $y2) (i32.const 7)))  ;;  7^7 = 823543
      )
    )
  )
)

(assert_return (invoke "syntax" (i32.const 1) (i64.const 2)))

(assert_return (invoke "pow" (i64.const 17) (i32.const 0)) (i64.const 1))
(assert_return (invoke "pow" (i64.const 19) (i32.const 1)) (i64.const 19))
(assert_return (invoke "pow" (i64.const 11) (i32.const 2)) (i64.const 121))
(assert_return (invoke "pow" (i64.const 13) (i32.const 3)) (i64.const 2197))
(assert_return (invoke "pow" (i64.const 2) (i32.const 4)) (i64.const 16))
(assert_return (invoke "pow" (i64.const 3) (i32.const 5)) (i64.const 243))
(assert_return (invoke "pow" (i64.const 5) (i32.const 6)) (i64.const 15625))
(assert_return (invoke "pow" (i64.const 7) (i32.const 7)) (i64.const 823543))

(assert_return (invoke "semantics-idx" (i64.const 2) (i64.const 3)) (i64.const 841_765))
(assert_return (invoke "semantics-sym" (i64.const 2) (i64.const 3)) (i64.const 841_765))
