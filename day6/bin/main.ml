let input = "input.in"

let test = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
let test2 = "bvwbjplbgvbhsrlpgdmjqwftvncz"
let test3 = "nppdvjthqldpwncqszvftbrmjlhg"

let rec unique list =
    match list with
    | [] -> false
    | [_] -> true
    | x::xs -> 
            let mapped = List.map (fun y -> x != y) xs in
            if List.fold_left (fun a b -> a && b) true mapped then
                unique xs
            else
                false;;

unique ['a'; 'b'; 'a'; 'd'];;
unique ['a'; 'b'; 'c'; 'd'];;
unique ['a'; 'b'; 'c'; 'd'; 'e'; 'f'; 'g'];;

let push list elem = 
    match list with
    | a::b::c::_ -> [elem; a; b; c]
    | _ -> elem::list;;

push ['a'; 'b'; 'c'; 'd'] 'a';;
push ['a'; 'b'; 'c'] 'c';;

let push2 size list elem = 
    let rec aux elem acc i list =
        match i, list with
            | 0, _ -> elem::(List.rev acc)
            | i, x::xs -> aux elem (x::acc) (i-1) xs
            | _, [] -> assert false
            in
        aux elem [] (size-1) list;;

push2 5 ['a'; 'b'; 'c'; 'd'; 'e'] 'f';;
'f'::['a'; 'b'; 'c'; 'd'];;

let process str = 
    let rec aux i acc = function
        | [] -> i
        | x::xs -> 
                let size = 14 in
                if i < size then
                    aux (i+1) (x::acc) xs
                else if unique acc then
                    i
                else
                    aux (i+1) (push2 size acc x) xs
        in
    aux 0 [] ((String.to_seq str) |> List.of_seq);;

process test;;
process test2;;
process test3;;

let () = 
    let ic = open_in input in
    try
        let line = input_line ic in
        process line |> print_int;
        prerr_newline ()
    with e ->
        close_in_noerr ic;
        raise e;;

    
