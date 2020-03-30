;; Syntactic types

;; Simple types.

(module
  (type $t1 (func (param f32 f32) (result f32)))
  (type $t2 (func (param $x f32) (param $y f32) (result f32)))

  (func $f1 (param $r (ref $t1)) (call $f2 (local.get $r)))
  (func $f2 (param $r (ref $t2)) (call $f1 (local.get $r)))
)


;; Indirect types.

(module
  (type $s0 (func (param i32) (result f32)))
  (type $s1 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $s2 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $t1 (func (param (ref $s1)) (result (ref $s2))))
  (type $t2 (func (param (ref $s2)) (result (ref $s1))))

  (func $f1 (param $r (ref $t1)) (call $f2 (local.get $r)))
  (func $f2 (param $r (ref $t2)) (call $f1 (local.get $r)))
)


;; Recursive types.

(module
  (type $t1 (func (param i32 (ref $t1))))
  (type $t2 (func (param i32 (ref $t2))))

  (func $f1 (param $r (ref $t1)) (call $f2 (local.get $r)))
  (func $f2 (param $r (ref $t2)) (call $f1 (local.get $r)))
)


;; Isomorphic recursive types.

(module
  (type $t1 (func (param i32 (ref $t1))))
  (type $t2 (func (param i32 (ref $t3))))
  (type $t3 (func (param i32 (ref $t2))))

  (func $f1 (param $r (ref $t1))
    (call $f2 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f2 (param $r (ref $t2))
    (call $f1 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f3 (param $r (ref $t3))
    (call $f1 (local.get $r))
    (call $f2 (local.get $r))
  )
)

(module
  (type $t1 (func (param i32 (ref $t3))))
  (type $t2 (func (param i32 (ref $t1))))
  (type $t3 (func (param i32 (ref $t2))))

  (func $f1 (param $r (ref $t1))
    (call $f2 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f2 (param $r (ref $t2))
    (call $f1 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f3 (param $r (ref $t3))
    (call $f1 (local.get $r))
    (call $f2 (local.get $r))
  )
)

(module
  (type $t1 (func (param i32 (ref $u1))))
  (type $u1 (func (param f32 (ref $t1))))

  (type $t2 (func (param i32 (ref $u3))))
  (type $u2 (func (param f32 (ref $t3))))
  (type $t3 (func (param i32 (ref $u2))))
  (type $u3 (func (param f32 (ref $t2))))

  (func $f1 (param $r (ref $t1))
    (call $f2 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f2 (param $r (ref $t2))
    (call $f1 (local.get $r))
    (call $f3 (local.get $r))
  )
  (func $f3 (param $r (ref $t3))
    (call $f1 (local.get $r))
    (call $f2 (local.get $r))
  )
)


;; Semantic types

;; Simple types.

(module
  (type $t1 (func (param f32 f32) (result f32)))
  (func (export "f") (param (ref $t1)))
)
(register "M")
(module
  (type $t2 (func (param $x f32) (param $y f32) (result f32)))
  (func (import "M" "f") (param (ref $t2)))
)


;; Indirect types.

(module
  (type $s0 (func (param i32) (result f32)))
  (type $s1 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $s2 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $t1 (func (param (ref $s1)) (result (ref $s2))))
  (type $t2 (func (param (ref $s2)) (result (ref $s1))))
  (func (export "f1") (param (ref $t1)))
  (func (export "f2") (param (ref $t1)))
)
(register "M")
(module
  (type $s0 (func (param i32) (result f32)))
  (type $s1 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $s2 (func (param i32 (ref $s0)) (result (ref $s0))))
  (type $t1 (func (param (ref $s1)) (result (ref $s2))))
  (type $t2 (func (param (ref $s2)) (result (ref $s1))))
  (func (import "M" "f1") (param (ref $t1)))
  (func (import "M" "f1") (param (ref $t2)))
  (func (import "M" "f2") (param (ref $t1)))
  (func (import "M" "f2") (param (ref $t1)))
)


;; Recursive types.

(module
  (type $t1 (func (param i32 (ref $t1))))
  (func (export "f") (param (ref $t1)))
)
(register "M")
(module
  (type $t2 (func (param i32 (ref $t2))))
  (func (import "M" "f") (param (ref $t2)))
)


;; Isomorphic recursive types.

(module
  (type $t1 (func (param i32 (ref $t1))))
  (type $t2 (func (param i32 (ref $t3))))
  (type $t3 (func (param i32 (ref $t2))))
  (func (export "f1") (param (ref $t1)))
  (func (export "f2") (param (ref $t2)))
  (func (export "f3") (param (ref $t3)))
)
(register "M")
(module
  (type $t1 (func (param i32 (ref $t1))))
  (type $t2 (func (param i32 (ref $t3))))
  (type $t3 (func (param i32 (ref $t2))))
  (func (import "M" "f1") (param (ref $t1)))
  (func (import "M" "f1") (param (ref $t2)))
  (func (import "M" "f1") (param (ref $t3)))
  (func (import "M" "f2") (param (ref $t1)))
  (func (import "M" "f2") (param (ref $t2)))
  (func (import "M" "f2") (param (ref $t3)))
  (func (import "M" "f3") (param (ref $t1)))
  (func (import "M" "f3") (param (ref $t2)))
  (func (import "M" "f3") (param (ref $t3)))
)

(module
  (type $t1 (func (param i32 (ref $t3))))
  (type $t2 (func (param i32 (ref $t1))))
  (type $t3 (func (param i32 (ref $t2))))
  (func (export "f1") (param (ref $t1)))
  (func (export "f2") (param (ref $t2)))
  (func (export "f3") (param (ref $t3)))
)
(register "M")
(module
  (type $t1 (func (param i32 (ref $t3))))
  (type $t2 (func (param i32 (ref $t1))))
  (type $t3 (func (param i32 (ref $t2))))
  (func (import "M" "f1") (param (ref $t1)))
  (func (import "M" "f1") (param (ref $t2)))
  (func (import "M" "f1") (param (ref $t3)))
  (func (import "M" "f2") (param (ref $t1)))
  (func (import "M" "f2") (param (ref $t2)))
  (func (import "M" "f2") (param (ref $t3)))
  (func (import "M" "f3") (param (ref $t1)))
  (func (import "M" "f3") (param (ref $t2)))
  (func (import "M" "f3") (param (ref $t3)))
)

(module
  (type $t1 (func (param i32 (ref $u1))))
  (type $u1 (func (param f32 (ref $t1))))

  (type $t2 (func (param i32 (ref $u3))))
  (type $u2 (func (param f32 (ref $t3))))
  (type $t3 (func (param i32 (ref $u2))))
  (type $u3 (func (param f32 (ref $t2))))

  (func (export "f1") (param (ref $t1)))
  (func (export "f2") (param (ref $t2)))
  (func (export "f3") (param (ref $t3)))
)
(register "M")
(module
  (type $t1 (func (param i32 (ref $u1))))
  (type $u1 (func (param f32 (ref $t1))))

  (type $t2 (func (param i32 (ref $u3))))
  (type $u2 (func (param f32 (ref $t3))))
  (type $t3 (func (param i32 (ref $u2))))
  (type $u3 (func (param f32 (ref $t2))))

  (func (import "M" "f1") (param (ref $t1)))
  (func (import "M" "f1") (param (ref $t2)))
  (func (import "M" "f1") (param (ref $t3)))
  (func (import "M" "f2") (param (ref $t1)))
  (func (import "M" "f2") (param (ref $t2)))
  (func (import "M" "f2") (param (ref $t3)))
  (func (import "M" "f3") (param (ref $t1)))
  (func (import "M" "f3") (param (ref $t2)))
  (func (import "M" "f3") (param (ref $t3)))
)