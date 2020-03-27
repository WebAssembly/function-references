module Var =
struct
  type def = ..
  type t = def ref
  let to_string' = ref (fun (x : t) -> (failwith "dummy" : string))
  let to_string x = !to_string' x
end

include Types.Make (Var)

type Var.def += Def of def_type

let def_of x =
  match !x with
  | Def dt -> dt
  | _ -> assert false


(* String conversion *)

let _ = Var.to_string' :=
  fun x -> "(" ^ string_of_def_type (def_of x) ^ ")"


(* Allocation *)

let alloc_nullability = function
  | Types.NonNullable -> NonNullable
  | Types.Nullable -> Nullable

let alloc_mutability = function
  | Types.Immutable -> Immutable
  | Types.Mutable -> Mutable


let alloc_num_type = function
  | Types.I32Type -> I32Type
  | Types.I64Type -> I64Type
  | Types.F32Type -> F32Type
  | Types.F64Type -> F64Type

let alloc_ref_type c = function
  | Types.NullRefType -> NullRefType
  | Types.AnyRefType -> AnyRefType
  | Types.FuncRefType -> FuncRefType
  | Types.DefRefType (nul, x) ->
    DefRefType (alloc_nullability nul, Lib.List32.nth c x)

let alloc_value_type c = function
  | Types.NumType t -> NumType (alloc_num_type t)
  | Types.RefType t -> RefType (alloc_ref_type c t)
  | Types.BotType -> BotType

let alloc_stack_type c ts =
 List.map (alloc_value_type c) ts


let alloc_limits {Types.min; max} = {min; max}

let alloc_memory_type c (Types.MemoryType lim) =
  MemoryType(alloc_limits lim)

let alloc_table_type c (Types.TableType (lim, t)) =
  TableType (alloc_limits lim, alloc_ref_type c t)

let alloc_global_type c (Types.GlobalType (t, mut)) =
  GlobalType (alloc_value_type c t, alloc_mutability mut)

let alloc_func_type c (Types.FuncType (ins, out)) =
  FuncType (alloc_stack_type c ins, alloc_stack_type c out)

let alloc_extern_type c = function
  | Types.ExternFuncType ft -> ExternFuncType (alloc_func_type c ft)
  | Types.ExternTableType tt -> ExternTableType (alloc_table_type c tt)
  | Types.ExternMemoryType mt -> ExternMemoryType (alloc_memory_type c mt)
  | Types.ExternGlobalType gt -> ExternGlobalType (alloc_global_type c gt)


let alloc_def_type c = function
  | Types.FuncDefType ft -> FuncDefType (alloc_func_type c ft)

let alloc dt = ref (Def dt)


let alloc_export_type c (Types.ExportType (et, name)) =
  ExportType (alloc_extern_type c et, name)

let alloc_import_type c (Types.ImportType (et, module_name, name)) =
  ImportType (alloc_extern_type c et, module_name, name)

let alloc_module_type (Types.ModuleType (dts, its, ets)) =
  let dummy_type = FuncDefType (FuncType ([], [])) in
  let c = List.map (fun _ -> alloc dummy_type) dts in
  List.iter2 (fun x dt -> x := Def (alloc_def_type c dt)) c dts;
  let its = List.map (alloc_import_type c) its in
  let ets = List.map (alloc_export_type c) ets in
  ModuleType ([], its, ets)


(* Type matching *)

module Context =
struct
  type t = unit
  let lookup c = def_of
end

module Match = Match.Make (Var) (Context)
