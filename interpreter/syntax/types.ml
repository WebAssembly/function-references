(* Types *)

module type VAR =
sig
  type t
  val equal : t -> t -> bool
  val to_string : t -> string
end

module Make (Var : VAR) =
struct
  type var = Var.t
  type name = int list

  type nullability = NonNullable | Nullable
  type num_type = I32Type | I64Type | F32Type | F64Type
  type ref_type =
    | NullRefType
    | AnyRefType
    | FuncRefType
    | DefRefType of nullability * var

  type value_type = NumType of num_type | RefType of ref_type | BotType
  type stack_type = value_type list
  type func_type = FuncType of stack_type * stack_type
  type def_type = FuncDefType of func_type

  type 'a limits = {min : 'a; max : 'a option}
  type mutability = Immutable | Mutable
  type table_type = TableType of Int32.t limits * ref_type
  type memory_type = MemoryType of Int32.t limits
  type global_type = GlobalType of value_type * mutability
  type extern_type =
    | ExternFuncType of func_type
    | ExternTableType of table_type
    | ExternMemoryType of memory_type
    | ExternGlobalType of global_type

  type export_type = ExportType of extern_type * name
  type import_type = ImportType of extern_type * name * name
  type module_type =
    ModuleType of def_type list * import_type list * export_type list


  (* Projections *)

  let as_func_def_type (dt : def_type) : func_type =
    match dt with
    | FuncDefType ft -> ft

  let extern_type_of_import_type (ImportType (et, _, _)) = et
  let extern_type_of_export_type (ExportType (et, _)) = et


  (* Attributes *)

  let size = function
    | I32Type | F32Type -> 4
    | I64Type | F64Type -> 8

  let is_num_type = function
    | NumType _ | BotType -> true
    | RefType _ -> false

  let is_ref_type = function
    | NumType _ -> false
    | RefType _ | BotType -> true

  let defaultable_num_type = function
    | _ -> true

  let defaultable_ref_type = function
    | AnyRefType | NullRefType | FuncRefType | DefRefType (Nullable, _) -> true
    | DefRefType (NonNullable, _) -> false

  let defaultable_value_type = function
    | NumType t -> defaultable_num_type t
    | RefType t -> defaultable_ref_type t
    | BotType -> false


  (* Filters *)

  let funcs =
    Lib.List.map_filter (function ExternFuncType t -> Some t | _ -> None)
  let tables =
    Lib.List.map_filter (function ExternTableType t -> Some t | _ -> None)
  let memories =
    Lib.List.map_filter (function ExternMemoryType t -> Some t | _ -> None)
  let globals =
    Lib.List.map_filter (function ExternGlobalType t -> Some t | _ -> None)


  (* String conversion *)

  let string_of_nullability = function
    | NonNullable -> ""
    | Nullable -> "null "

  let string_of_num_type = function
    | I32Type -> "i32"
    | I64Type -> "i64"
    | F32Type -> "f32"
    | F64Type -> "f64"

  let string_of_ref_type = function
    | NullRefType -> "nullref"
    | AnyRefType -> "anyref"
    | FuncRefType -> "funcref"
    | DefRefType (nul, x) ->
      "(ref " ^ string_of_nullability nul ^ Var.to_string x ^ ")"

  let string_of_value_type = function
    | NumType t -> string_of_num_type t
    | RefType t -> string_of_ref_type t
    | BotType -> "impossible"

  let string_of_stack_type = function
    | [t] -> string_of_value_type t
    | ts -> "[" ^ String.concat " " (List.map string_of_value_type ts) ^ "]"


  let string_of_limits {min; max} =
    I32.to_string_u min ^
    (match max with None -> "" | Some n -> " " ^ I32.to_string_u n)

  let string_of_memory_type = function
    | MemoryType lim -> string_of_limits lim

  let string_of_table_type = function
    | TableType (lim, t) -> string_of_limits lim ^ " " ^ string_of_ref_type t

  let string_of_global_type = function
    | GlobalType (t, Immutable) -> string_of_value_type t
    | GlobalType (t, Mutable) -> "(mut " ^ string_of_value_type t ^ ")"

  let string_of_func_type = function
    | FuncType (ins, out) ->
      string_of_stack_type ins ^ " -> " ^ string_of_stack_type out

  let string_of_extern_type = function
    | ExternFuncType ft -> "func " ^ string_of_func_type ft
    | ExternTableType tt -> "table " ^ string_of_table_type tt
    | ExternMemoryType mt -> "memory " ^ string_of_memory_type mt
    | ExternGlobalType gt -> "global " ^ string_of_global_type gt


  let string_of_def_type = function
    | FuncDefType ft -> "func " ^ string_of_func_type ft


  let string_of_name n =
    let b = Buffer.create 16 in
    let escape uc =
      if uc < 0x20 || uc >= 0x7f then
        Buffer.add_string b (Printf.sprintf "\\u{%02x}" uc)
      else begin
        let c = Char.chr uc in
        if c = '\"' || c = '\\' then Buffer.add_char b '\\';
        Buffer.add_char b c
      end
    in
    List.iter escape n;
    Buffer.contents b

  let string_of_export_type (ExportType (et, name)) =
    "\"" ^ string_of_name name ^ "\" : " ^ string_of_extern_type et 

  let string_of_import_type (ImportType (et, module_name, name)) =
    "\"" ^ string_of_name module_name ^ "\" \"" ^
      string_of_name name ^ "\" : " ^ string_of_extern_type et

  let string_of_module_type (ModuleType (dts, its, ets)) =
    String.concat "" (
      List.mapi (fun i dt -> "type " ^ string_of_int i ^ " = " ^ string_of_def_type dt ^ "\n") dts @
      List.map (fun it -> "import " ^ string_of_import_type it ^ "\n") its @
      List.map (fun et -> "export " ^ string_of_export_type et ^ "\n") ets
    )
end

(* Syntactic Types *)

module Syn =
struct
  module Var = Int32

  include Make (Var)
end


(* Semantic Types *)

module Sem =
struct
  module Var =
  struct
    type def = ..
    type t = def ref
    let equal = (==)
    let to_string' = ref (fun (x : t) -> (failwith "dummy" : string))
    let to_string x = !to_string' x
  end

  include Make (Var)

  type Var.def += Def of def_type

  let def_of x =
    match !x with
    | Def dt -> dt
    | _ -> assert false

  let _ = Var.to_string' :=
    let inner = ref false in
    fun x ->
      if !inner then "..." else
      ( inner := true;
        try let s = string_of_def_type (def_of x) in inner := false; "(" ^ s ^ ")"
        with exn -> inner := false; raise exn
      )
end


(* Allocation *)

let alloc dt = ref (Sem.Def dt)


(* Conversion *)

let sem_nullability = function
  | Syn.NonNullable -> Sem.NonNullable
  | Syn.Nullable -> Sem.Nullable

let sem_mutability = function
  | Syn.Immutable -> Sem.Immutable
  | Syn.Mutable -> Sem.Mutable


let sem_num_type = function
  | Syn.I32Type -> Sem.I32Type
  | Syn.I64Type -> Sem.I64Type
  | Syn.F32Type -> Sem.F32Type
  | Syn.F64Type -> Sem.F64Type

let sem_ref_type c = function
  | Syn.NullRefType -> Sem.NullRefType
  | Syn.AnyRefType -> Sem.AnyRefType
  | Syn.FuncRefType -> Sem.FuncRefType
  | Syn.DefRefType (nul, x) ->
    Sem.DefRefType (sem_nullability nul, Lib.List32.nth c x)

let sem_value_type c = function
  | Syn.NumType t -> Sem.NumType (sem_num_type t)
  | Syn.RefType t -> Sem.RefType (sem_ref_type c t)
  | Syn.BotType -> Sem.BotType

let sem_stack_type c ts =
 List.map (sem_value_type c) ts


let sem_limits {Syn.min; max} = {Sem.min; max}

let sem_memory_type c (Syn.MemoryType lim) =
  Sem.MemoryType (sem_limits lim)

let sem_table_type c (Syn.TableType (lim, t)) =
  Sem.TableType (sem_limits lim, sem_ref_type c t)

let sem_global_type c (Syn.GlobalType (t, mut)) =
  Sem.GlobalType (sem_value_type c t, sem_mutability mut)

let sem_func_type c (Syn.FuncType (ins, out)) =
  Sem.FuncType (sem_stack_type c ins, sem_stack_type c out)

let sem_extern_type c = function
  | Syn.ExternFuncType ft -> Sem.ExternFuncType (sem_func_type c ft)
  | Syn.ExternTableType tt -> Sem.ExternTableType (sem_table_type c tt)
  | Syn.ExternMemoryType mt -> Sem.ExternMemoryType (sem_memory_type c mt)
  | Syn.ExternGlobalType gt -> Sem.ExternGlobalType (sem_global_type c gt)


let sem_def_type c = function
  | Syn.FuncDefType ft -> Sem.FuncDefType (sem_func_type c ft)


let sem_export_type c (Syn.ExportType (et, name)) =
  Sem.ExportType (sem_extern_type c et, name)

let sem_import_type c (Syn.ImportType (et, module_name, name)) =
  Sem.ImportType (sem_extern_type c et, module_name, name)

let sem_module_type (Syn.ModuleType (dts, its, ets)) =
  let dummy_type = Sem.FuncDefType (Sem.FuncType ([], [])) in
  let c = List.map (fun _ -> alloc dummy_type) dts in
  List.iter2 (fun x dt -> x := Sem.Def (sem_def_type c dt)) c dts;
  let its = List.map (sem_import_type c) its in
  let ets = List.map (sem_export_type c) ets in
  Sem.ModuleType ([], its, ets)
