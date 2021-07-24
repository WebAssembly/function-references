Types
-----

Simple :ref:`types <syntax-type>`, such as :ref:`number types <syntax-numtype>` are universally valid.
However, restrictions apply to most other types, such as :ref:`reference types <syntax-reftype>`, :ref:`function types <syntax-functype>`, as well as the :ref:`limits <syntax-limits>` of :ref:`table types <syntax-tabletype>` and :ref:`memory types <syntax-memtype>`, which must be checked during validation.

Moreover, :ref:`block types <syntax-blocktype>` are converted to plain :ref:`function types <syntax-functype>` for ease of processing.

On most types, a simple notion of subtyping is defined that is applicable in validation rules or during :ref:`module instantiation <exec-instantiation>`.


.. index:: number type
   pair: validation; number type
   single: abstract syntax; number type
.. _valid-numtype:

Number Types
~~~~~~~~~~~~

:ref:`Number types <syntax-numtype>` are always valid.

.. math::
   \frac{
   }{
     C \vdashnumtype \numtype \ok
   }


.. index:: heap type
   pair: validation; heap type
   single: abstract syntax; heap type
.. _valid-heaptype:

Heap Types
~~~~~~~~~~

Concrete :ref:`Heap types <syntax-heaptype>` are only valid when the :ref:`type index <syntax-typeidx>` is.

:math:`\FUNC`
.............

* The heap type is valid.

.. math::
   \frac{
   }{
     C \vdashheaptype \FUNC \ok
   }

:math:`\EXTERN`
...............

* The heap type is valid.

.. math::
   \frac{
   }{
     C \vdashheaptype \EXTERN \ok
   }

:math:`\typeidx`
................

* The type :math:`C.\CTYPES[\typeidx]` must be defined in the context.

* Then the heap type is valid.

.. math::
   \frac{
     C.\CTYPES[\typeidx] = \functype
   }{
     C \vdashheaptype \typeidx \ok
   }


.. index:: reference type, heap type
   pair: validation; reference type
   single: abstract syntax; reference type
.. _valid-reftype:

Reference Types
~~~~~~~~~~~~~~~

:ref:`Reference types <syntax-reftype>` are valid when the referenced :ref:`heap type <syntax-heaptype>` is.

:math:`\REF~\NULL^?~\heaptype`
..............................

* The heap type :math:`\heaptype` must be :ref:`valid <valid-heaptype>`.

* Then the reference type is valid.

.. math::
   \frac{
     C \vdashreftype \heaptype \ok
   }{
     C \vdashreftype \REF~\NULL^?~\heaptype \ok
   }


.. index:: value type, reference type, heap type, bottom type
   pair: validation; value type
   single: abstract syntax; value type
.. _valid-valtype:
.. _valid-bottype:

Value Types
~~~~~~~~~~~

Valid :ref:`value types <syntax-valtype>` are either valid :ref:`number type <valid-numtype>`,  :ref:`reference type <valid-reftype>`, or the :ref:`bottom type <syntax-bottype>`.

:math:`\BOT`
............

* The value type is valid.

.. math::
   \frac{
   }{
     C \vdashvaltype \BOT \ok
   }


.. index:: result type, value type
   pair: validation; result type
   single: abstract syntax; result type
.. _valid-resulttype:

Result Types
~~~~~~~~~~~~

:math:`[t^\ast]`
................

* Each :ref:`value type <syntax-valtype>` :math:`t_i` in the type sequence :math:`t^\ast` must be :ref:`valid <valid-valtype>`.

* Then the result type is valid.

.. math::
   \frac{
     (C \vdashvaltype t \ok)^\ast
   }{
     C \vdashresulttype [t^\ast] \ok
   }


.. index:: limits
   pair: validation; limits
   single: abstract syntax; limits
.. _valid-limits:

Limits
~~~~~~

:ref:`Limits <syntax-limits>` must have meaningful bounds that are within a given range.

:math:`\{ \LMIN~n, \LMAX~m^? \}`
................................

* The value of :math:`n` must not be larger than :math:`k`.

* If the maximum :math:`m^?` is not empty, then:

  * Its value must not be larger than :math:`k`.

  * Its value must not be smaller than :math:`n`.

* Then the limit is valid within range :math:`k`.

.. math::
   \frac{
     n \leq k
     \qquad
     (m \leq k)^?
     \qquad
     (n \leq m)^?
   }{
     C \vdashlimits \{ \LMIN~n, \LMAX~m^? \} : k
   }


.. index:: block type
   pair: validation; block type
   single: abstract syntax; block type
.. _valid-blocktype:

Block Types
~~~~~~~~~~~

:ref:`Block types <syntax-blocktype>` may be expressed in one of two forms, both of which are converted to plain :ref:`function types <syntax-functype>` by the following rules.

:math:`\typeidx`
................

* The type :math:`C.\CTYPES[\typeidx]` must be defined in the context.

* Then the block type is valid as :ref:`function type <syntax-functype>` :math:`C.\CTYPES[\typeidx]`.

.. math::
   \frac{
     C.\CTYPES[\typeidx] = \functype
   }{
     C \vdashblocktype \typeidx : \functype
   }


:math:`[\valtype^?]`
....................

* The value type :math:`\valtype` must either be absent, or :ref:`valid <valid-valtype>`.

* Then the block type is valid as :ref:`function type <syntax-functype>` :math:`[] \to [\valtype^?]`.

.. math::
   \frac{
     (C \vdashvaltype \valtype \ok)^?
   }{
     C \vdashblocktype [\valtype^?] : [] \to [\valtype^?]
   }


.. index:: function type
   pair: validation; function type
   single: abstract syntax; function type
.. _valid-functype:

Function Types
~~~~~~~~~~~~~~

:math:`[t_1^\ast] \to [t_2^\ast]`
.................................

* The :ref:`result type <syntax-resulttype>` :math:`[t_1^\ast]` must be :ref:`valid <valid-resulttype>`.

* The :ref:`result type <syntax-resulttype>` :math:`[t_2^\ast]` must be :ref:`valid <valid-resulttype>`.

* Then the function type is valid.

.. math::
   \frac{
     C \vdashvaltype [t_1^\ast] \ok
     \qquad
     C \vdashvaltype [t_2^\ast] \ok
   }{
     C \vdashfunctype [t_1^\ast] \to [t_2^\ast] \ok
   }


.. index:: table type, reference type, limits
   pair: validation; table type
   single: abstract syntax; table type
.. _valid-tabletype:

Table Types
~~~~~~~~~~~

:math:`\limits~\reftype`
........................

* The limits :math:`\limits` must be :ref:`valid <valid-limits>` within range :math:`2^{32}-1`.

* The reference type :math:`\reftype` must be :ref:`valid <valid-reftype>`.

* Then the table type is valid.

.. math::
   \frac{
     C \vdashlimits \limits : 2^{32} - 1
     \qquad
     C \vdashreftype \reftype \ok
   }{
     C \vdashtabletype \limits~\reftype \ok
   }


.. index:: memory type, limits
   pair: validation; memory type
   single: abstract syntax; memory type
.. _valid-memtype:

Memory Types
~~~~~~~~~~~~

:math:`\limits`
...............

* The limits :math:`\limits` must be :ref:`valid <valid-limits>` within range :math:`2^{16}`.

* Then the memory type is valid.

.. math::
   \frac{
     C \vdashlimits \limits : 2^{16}
   }{
     C \vdashmemtype \limits \ok
   }


.. index:: global type, value type, mutability
   pair: validation; global type
   single: abstract syntax; global type
.. _valid-globaltype:

Global Types
~~~~~~~~~~~~

:math:`\mut~\valtype`
.....................

* The value type :math:`\valtype` must be :ref:`valid <valid-valtype>`.

* Then the global type is valid.

.. math::
   \frac{
     C \vdashreftype \valtype \ok
   }{
     C \vdashglobaltype \mut~\valtype \ok
   }


.. index:: external type, function type, table type, memory type, global type
   pair: validation; external type
   single: abstract syntax; external type
.. _valid-externtype:

External Types
~~~~~~~~~~~~~~

:math:`\ETFUNC~\functype`
.........................

* The :ref:`function type <syntax-functype>` :math:`\functype` must be :ref:`valid <valid-functype>`.

* Then the external type is valid.

.. math::
   \frac{
     C \vdashfunctype \functype \ok
   }{
     C \vdashexterntype \ETFUNC~\functype \ok
   }

:math:`\ETTABLE~\tabletype`
...........................

* The :ref:`table type <syntax-tabletype>` :math:`\tabletype` must be :ref:`valid <valid-tabletype>`.

* Then the external type is valid.

.. math::
   \frac{
     C \vdashtabletype \tabletype \ok
   }{
     C \vdashexterntype \ETTABLE~\tabletype \ok
   }

:math:`\ETMEM~\memtype`
.......................

* The :ref:`memory type <syntax-memtype>` :math:`\memtype` must be :ref:`valid <valid-memtype>`.

* Then the external type is valid.

.. math::
   \frac{
     C \vdashmemtype \memtype \ok
   }{
     C \vdashexterntype \ETMEM~\memtype \ok
   }

:math:`\ETGLOBAL~\globaltype`
.............................

* The :ref:`global type <syntax-globaltype>` :math:`\globaltype` must be :ref:`valid <valid-globaltype>`.

* Then the external type is valid.

.. math::
   \frac{
     C \vdashglobaltype \globaltype \ok
   }{
     C \vdashexterntype \ETGLOBAL~\globaltype \ok
   }
 

.. index:: subtyping

.. todo:: move subtyping rules to a separate section, so that sections are at the same nesting level as wf rules?

Value Subtyping
~~~~~~~~~~~~~~~

.. index:: number type

.. _match-numtype:

Number Types
............

A :ref:`number type <syntax-numtype>` :math:`\numtype_1` matches a :ref:`number type <syntax-numtype>` :math:`\numtype_2` if and only if:

* Both :math:`\numtype_1` and :math:`\numtype_2` are the same.

.. math::
   ~\\[-1ex]
   \frac{
   }{
     C \vdashnumtypematch \numtype \matchesvaltype \numtype
   }


.. index:: heap type

.. _match-heaptype:

Heap Types
..........

A :ref:`heap type <syntax-heaptype>` :math:`\heaptype_1` matches a :ref:`heap type <syntax-heaptype>` :math:`\heaptype_2` if and only if:

* Either both :math:`\heaptype_1` and :math:`\heaptype_2` are the same.

* Or :math:`\heaptype_1` is a :ref:`type index <syntax-typeidx>` that defines a function type and :math:`\heaptype_2` is :math:`FUNC`.

* Or :math:`\heaptype_1` is a :ref:`type index <syntax-typeidx>` that defines a function type :math:`\functype_1`, and :math:`\heaptype_2` is a :ref:`type index <syntax-typeidx>` that defines a function type :math:`\functype_2`, and :math:`\functype_1` :ref:`matches <match-functype>` :math:`\functype_2`.

.. math::
   ~\\[-1ex]
   \frac{
   }{
     C \vdashheaptypematch \heaptype \matchesheaptype \heaptype
   }
   \qquad
   \frac{
     C.\CTYPES[\typeidx] = \functype
   }{
     C \vdashheaptypematch \typeidx \matchesheaptype \FUNC
   }

.. math::
   ~\\[-1ex]
   \frac{
     C.\CTYPES[\typeidx_1] = \functype_1
     \qquad
     C.\CTYPES[\typeidx_2] = \functype_2
     \qquad
     C \vdashfunctypematch \functype_1 \matchesfunctype \functype_2
   }{
     C \vdashheaptypematch \typeidx_1 \matchesheaptype \typeidx_2
   }


.. index:: reference type

.. _match-reftype:

Reference Types
...............

A :ref:`reference type <syntax-reftype>` :math:`\REF~\NULL_1^?~heaptype_1` matches a :ref:`reference type <syntax-reftype>` :math:`\REF~\NULL_2^?~heaptype_2` if and only if:

* The :ref:`heap type <syntax-heaptype>` :math:`\heaptype_1` :ref:`matches <match-heaptype>` :math:`\heaptype_2`.

* :math:`\NULL_1` is absent or :math:`\NULL_2` is present.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashheaptypematch \heaptype_1 \matchesheaptype \heaptype_2
   }{
     C \vdashreftypematch \REF~\heaptype_1 \matchesreftype \REF~\heaptype_2
   }
   \qquad
   \frac{
     C \vdashheaptypematch \heaptype_1 \matchesheaptype \heaptype_2
   }{
     C \vdashreftypematch \REF~\NULL~\heaptype_1 \matchesreftype \REF~\NULL^?~\heaptype_2
   }


.. index:: value type, number type, reference type
.. _match-valtype:

Value Types
...........

A :ref:`value type <syntax-valtype>` :math:`\valtype_1` matches a :ref:`value type <syntax-valtype>` :math:`\valtype_2` if and only if:

* Either both :math:`\valtype_1` and :math:`\valtype_2` are :ref:`number types <syntax-numtype>` and :math:`\valtype_1` :ref:`matches <match-numtype>` :math:`\valtype_2`.

* Or both :math:`\valtype_1` and :math:`\valtype_2` are :ref:`reference types <syntax-reftype>` and :math:`\valtype_1` :ref:`matches <match-reftype>` :math:`\valtype_2`.

* Or :math:`\valtype_1` is :math:`\BOT`.

.. math::
   ~\\[-1ex]
   \frac{
   }{
     C \vdashvaltypematch \BOT \matchesvaltype \valtype
   }


.. index:: result type, value type
.. _match-resulttype:

Result Types
............

Subtyping is lifted to :ref:`result types <syntax-resulttype>` in a pointwise manner.
That is, a :ref:`result type <syntax-resulttype>` :math:`[t_1^\ast]` matches a :ref:`result type <syntax-resulttype>` :math:`[t_2^\ast]` if and only if:

* Every :ref:`value type <syntax-valtype>` :math:`t_1` in :math:`[t_1^\ast]` :ref:`matches <match-valtype>` the corresponding :ref:`value type <syntax-valtype>` :math:`t_2` in :math:`[t_2^\ast]`.

.. math::
   ~\\[-1ex]
   \frac{
     (C \vdashvaltypematch t_1 \matchesvaltype t_2)^\ast
   }{
     C \vdashresulttypematch [t_1^\ast] \matchesresulttype [t_2^\ast]
   }


.. index:: function type, result type
.. _match-functype:

Function Types
..............

Subtyping is also defined for :ref:`function types <syntax-functype>`.
However, it is required that they match in both directions, effectively demanding type equivalence.
That is, a :ref:`function type <syntax-functype>` :math:`[t_{11}^\ast] \to [t_{12}^\ast]` matches a type :math:`[t_{21}^ast] \to [t_{22}^\ast]` if and only if:

* The :ref:`result type <syntax-resulttype>` :math:`[t_{11}^\ast]` :ref:`matches <match-resulttype>` :math:`[t_{21}^\ast]`, and vice versa.

* The :ref:`result type <syntax-resulttype>` :math:`[t_{12}^\ast]` :ref:`matches <match-resulttype>` :math:`[t_{22}^\ast]`, and vice versa.

.. math::
   ~\\[-1ex]
   \frac{
     \begin{array}{@{}c@{}}
     C \vdashresulttypematch [t_{11}^\ast] \matchesresulttype [t_{21}^\ast]
     \qquad
     C \vdashresulttypematch [t_{12}^\ast] \matchesresulttype [t_{22}^\ast]
     \\
     C \vdashresulttypematch [t_{21}^\ast] \matchesresulttype [t_{11}^\ast]
     \qquad
     C \vdashresulttypematch [t_{22}^\ast] \matchesresulttype [t_{12}^\ast]
     \end{array}
   }{
     C \vdashfunctypematch [t_{11}^\ast] \to [t_{12}^\ast] \matchesfunctype [t_{21}^\ast] \to [t_{22}^\ast]
   }

.. note::
   In future versions of WebAssembly, subtyping on function types may be relaxed to support co- and contra-variance.


.. index:: limits
.. _match-limits:

Limits
......

:ref:`Limits <syntax-limits>` :math:`\{ \LMIN~n_1, \LMAX~m_1^? \}` match limits :math:`\{ \LMIN~n_2, \LMAX~m_2^? \}` if and only if:

* :math:`n_1` is larger than or equal to :math:`n_2`.

* Either:

  * :math:`m_2^?` is empty.

* Or:

  * Both :math:`m_1^?` and :math:`m_2^?` are non-empty.

  * :math:`m_1` is smaller than or equal to :math:`m_2`.

.. math::
   ~\\[-1ex]
   \frac{
     n_1 \geq n_2
   }{
     C \vdashlimitsmatch \{ \LMIN~n_1, \LMAX~m_1^? \} \matcheslimits \{ \LMIN~n_2, \LMAX~\epsilon \}
   }
   \quad
   \frac{
     n_1 \geq n_2
     \qquad
     m_1 \leq m_2
   }{
     C \vdashlimitsmatch \{ \LMIN~n_1, \LMAX~m_1 \} \matcheslimits \{ \LMIN~n_2, \LMAX~m_2 \}
   }


.. index:: table type, limits, element type
.. _match-tabletype:

Table Types
...........

A :ref:`table type <syntax-tabletype>` :math:`(\limits_1~\reftype_1)` matches :math:`(\limits_2~\reftype_2)` if and only if:

* Limits :math:`\limits_1` :ref:`match <match-limits>` :math:`\limits_2`.

* The :ref:`reference type <syntax-reftype>` :math:`\reftype_1` :ref:`matches <match-reftype>` :math:`\reftype_2`, and vice versa.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashlimitsmatch \limits_1 \matcheslimits \limits_2
     \qquad
     C \vdashreftypematch \reftype_1 \matchesreftype \reftype_2
     \qquad
     C \vdashreftypematch \reftype_2 \matchesreftype \reftype_1
   }{
     C \vdashtabletypematch \limits_1~\reftype_1 \matchestabletype \limits_2~\reftype_2
   }


.. index:: memory type, limits
.. _match-memtype:

Memory Types
............

A :ref:`memory type <syntax-memtype>` :math:`\limits_1` matches :math:`\limits_2` if and only if:

* Limits :math:`\limits_1` :ref:`match <match-limits>` :math:`\limits_2`.


.. math::
   ~\\[-1ex]
   \frac{
     C \vdashlimitsmatch \limits_1 \matcheslimits \limits_2
   }{
     C \vdashmemtypematch \limits_1 \matchesmemtype \limits_2
   }


.. index:: global type, value type, mutability
.. _match-globaltype:

Global Types
............

A :ref:`global type <syntax-globaltype>` :math:`(\mut_1~t_1)` matches :math:`(\mut_2~t_2)` if and only if:

* Either both :math:`\mut_1` and :math:`\mut_2` are |MVAR| and :math:`t_1` and :math:`t_2` are the same.
 
* Or both :math:`\mut_1` and :math:`\mut_2` are |MCONST| and :math:`t_1` :ref:`matches <match-valtype>` :math:`t_2`.

.. math::
   ~\\[-1ex]
   \frac{
   }{
     C \vdashglobaltypematch \MVAR~t \matchesglobaltype \MVAR~t
   }
   \qquad
   \frac{
     C \vdashvaltypematch t_1 \matchesvaltype t_2
   }{
     C \vdashglobaltypematch \MCONST~t_1 \matchesglobaltype \MCONST~t_2
   }


.. index:: ! matching, external type
.. _exec-import:
.. _match:

.. todo:: import matching needs to be defined on semantic types; probably move it to exec; need to define how to reinterpret C for semantic types

Import Subtyping
~~~~~~~~~~~~~~~~

When :ref:`instantiating <exec-module>` a module,
:ref:`external values <syntax-externval>` must be provided whose :ref:`types <valid-externval>` are *matched* against the respective :ref:`external types <syntax-externtype>` classifying each import.
In some cases, this allows for a simple form of subtyping, as defined here.


.. _match-externtype:

.. index:: function type
.. _match-externfunctype:

Functions
.........

An :ref:`external type <syntax-externtype>` :math:`\ETFUNC~\functype_1` matches :math:`\ETFUNC~\functype_2` if and only if:

* Function type :math:`\functype_1` :ref:`match <match-functype>` :math:`\functype_2`.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashfunctypematch \functype_1 \matchesfunctype \functype_2
   }{
     C \vdashexterntypematch \ETFUNC~\functype_1 \matchesexterntype \ETFUNC~\functype_2
   }


.. index:: table type
.. _match-externtabletype:

Tables
......

An :ref:`external type <syntax-externtype>` :math:`\ETTABLE~\tabletype_1` matches :math:`\ETTABLE~\tabletype_2` if and only if:

* Table type :math:`\tabletype_1` :ref:`match <match-tabletype>` :math:`\tabletype_2`.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashtabletypematch \tabletype_1 \matchestabletype \tabletype_2
   }{
     C \vdashexterntypematch \ETTABLE~tabletype_1 \matchesexterntype \ETTABLE~\tabletype_2
   }


.. index:: memory type
.. _match-externmemtype:

Memories
........

An :ref:`external type <syntax-externtype>` :math:`\ETMEM~\memtype_1` matches :math:`\ETMEM~\memtype_2` if and only if:

* Memory type :math:`\memtype_1` :ref:`match <match-memtype>` :math:`\memtype_2`.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashmemtypematch \memtype_1 \matchesmemtype \memtype_2
   }{
     C \vdashexterntypematch \ETMEM~memtype_1 \matchesexterntype \ETMEM~\memtype_2
   }


.. index:: global type
.. _match-externglobaltype:

Globals
.......

An :ref:`external type <syntax-externtype>` :math:`\ETGLOBAL~\globaltype_1` matches :math:`\ETGLOBAL~\globaltype_2` if and only if:

* Global type :math:`\globaltype_1` :ref:`match <match-globaltype>` :math:`\globaltype_2`.

.. math::
   ~\\[-1ex]
   \frac{
     C \vdashglobaltypematch \globaltype_1 \matchesglobaltype \globaltype_2
   }{
     C \vdashexterntypematch \ETGLOBAL~globaltype_1 \matchesexterntype \ETGLOBAL~\globaltype_2
   }
