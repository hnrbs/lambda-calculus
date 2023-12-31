open Lexer
open Ast

let _dbg_expr expr =
  print_endline (Printf.sprintf "dbg!expr: %s" (Ast.to_string expr));
  expr

let _dbg_tokens tokens = 
  print_endline (Printf.sprintf "dbg!tokens: %s" (Lexer.to_string tokens));
  tokens

let _dbg (expr, tokens) =
  _dbg_expr(expr), _dbg_tokens(tokens)

let rec parse tokens =
  let parse_var tokens =
    match tokens with
    | Identifier (var)::rem -> Var(var), rem 
    | _ -> failwith "parse_error: expecting identifier" in

  let parse_app l_expr r_tokens =
    let r_expr, rem = parse r_tokens in
    App(l_expr, r_expr), rem in

  let parse_context tokens =
    match parse tokens with
    | expr, [] -> expr, []
    | expr, RParen::rem -> expr, rem
    | l_expr, r_tokens -> 
        match parse_app l_expr r_tokens with
        | expr, [] -> expr, []
        | expr, RParen::rem -> expr, rem 
        | _expr, _rem -> failwith "parse_error: context not clossed" in

  let parse_abs tokens =
    (match tokens with
    | Lambda::Identifier(param)::Dot::body ->
        let body, rem = parse_context body in
        Abs(param, body), rem
    | _tokens -> failwith "parse_error: invalid function syntax") in 

  match tokens with
  | Identifier _::_rem -> parse_var(tokens)
  | Lambda::_ -> parse_abs(tokens)
  | LParen::rem -> parse_context(rem)
  | tokens -> failwith (Printf.sprintf "parse_error: invalid token (%s)" (Lexer.to_string tokens))

let parse tokens =
  let result = match tokens with
  | [] -> failwith "parse_error: no tokens were given"
  | tokens -> parse tokens in
  
  match result with
  | expr, [] -> expr
  | _expr, _tokens -> failwith "parse_error: remaining tokens"

