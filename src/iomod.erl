-module(iomod).
-export([
          in/1, 
          out/1, 
          cascade/3,
          out_json/2, 
          out_json/3,
          out_html/4,
          out_xml/3,
          fold_json/2,
          unfold_json/2,
          ip/1,
          strip/1,

          to_integer/1,
          to_integer/2,
          to_float/1,
          to_float/2,
          to_list/1,
          to_binary/1,
          integer_or_binary/1,

          cleanup_map/1,
          pwd_to_db_pwd/1,
          plain_pwd_to_db_pwd/1,
          generate_pwd/0,
          generate_pwd/2,
          smd5/2,
          random/0,
          random_str/3,
          random_num/2,
          split/1,
          concat/2,
          join/1,
          join/2,

          floor/1,
          ceiling/1,
          take_one/1,
          keys_to_lower/1,
          two_id_one_key/2,

          format_date_iso8601/1,
          date_to_timestamp/1,
          timestamp_to_date/1,
          parse_date/1,

          hash/1,
          sub/1, 
          pub/2, 
          unsub/1,
          subs/1,
          lookup/1,
          lookups/1,

          get_method/1,
          http_method_to_atom/1,
          get_request_body/1,
          get_request_json_body/1,
          get_request_multipart_body/1,

          escape_user_input/1
        ]).

-include("wa.hrl").

in(Msg) ->
  in(Msg, #{}).
in(Msg, Default) ->
  try jsx:decode(Msg, [return_maps]) of
    {error, Error} -> 
      ?ERROR("Error ~p in decoding ~p", [Error, Msg]),
      Default;
    {error, Error, Str} -> 
      ?ERROR("Error ~p in decoding ~p", [Error, Str]),
       Default;
    Data -> Data
  catch Exc:Exp -> 
    ?ERROR("Exception ~p:~p in decoding of ~p", [Exc, Exp, Msg]),
    Default 
  end.

out(Msg) ->
  try
    case jsx:encode(Msg) of
      Str when is_binary(Str) -> Str;
      Err -> 
        ?ERROR("Error encoding to JSON ~p in ~p", [Err, Msg]), 
        jsx:encode([])
    end
  catch 
    Exc:Exp -> 
      ?ERROR("Exception ~p:~p in encoding of ~p\n~p", [Exc, Exp, Msg, erlang:get_stacktrace()]),
      <<"{}">>
  end.
    
cascade(Map, Fields, Op) ->
  maps:map(fun(K, V) -> 
      case lists:any(fun(I) -> I =:= K end, Fields) of
        true -> ?MODULE:Op(V);
        false -> V
      end
    end, Map).

out_json(Msg, Req) ->
  out_json(200, Msg, Req).

out_json(Status, Msg, Req) ->
  {ok, Req1} = cowboy_req:reply(Status, [
        {<<"content-type">>, <<"application/json">>}
      ], out(Msg), Req),
  Req1.

out_html(Status, Tmpl, Context, Req) ->
  Headers = [
      {<<"content-type">>, <<"text/html; charset=UTF-8">>}
    ], 
  case Tmpl:render(Context) of
    {ok, Html} ->
      {ok, Req1} = cowboy_req:reply(Status, Headers, Html, Req),
      Req1;
    Any ->
      ?ERROR("Can't render template ~p for context ~p - ~p", [Tmpl, Context, Any]),
      Req
  end.

out_xml(Status, Body, Req) ->
  {ok, Req1} = cowboy_req:reply(Status, [
        {<<"content-type">>, <<"application/xml; charset=utf-8">>}
      ], Body, Req),
  Req1.

fold_json(Map, Fields) ->
  fold_json(Map, Fields, out).

unfold_json(Map, Fields) ->
  fold_json(Map, Fields, in).

fold_json(Map, Fields, Op) ->
  lists:foldl(fun
    ([H], M)  ->
      fold_json_replace(H, M, Op); 
    ([H | T], M) ->
      maps:put(H, fold_json(maps:get(H, M, #{}), [T], Op), M); 
    (I, M) -> 
      fold_json_replace(I, M, Op)
  end, Map, Fields).  

fold_json_replace(I, M, Op) ->
  case maps:get(I, M, null) of
    null ->
      maps:put(I, #{}, M);
    Val when is_binary(Val) ->
      maps:put(I, ?MODULE:Op(Val), M);
    _Any ->
      M
  end.

ip(Req) ->
  {{IP, _}, Req1} = cowboy_req:peer(Req),
  case cowboy_req:header(<<"x-real-ip">>, Req1, undefined) of
    {undefined, Req2} -> 
      {IP, Req2};
    {RealIP, Req2} ->
      case inet:parse_address(binary_to_list(RealIP)) of
        {ok, RIP} ->
          {RIP, Req2};
        _ ->
          {IP, Req2}
      end
  end.

strip(S) -> 
  re:replace(S, "[<>&/]+", "", [global,{return, binary}]).

to_integer(Val) -> to_integer(Val, 0).

to_integer(Int, _) when is_integer(Int) ->
  Int;
to_integer(IntB, Default) when is_binary(IntB) ->
  to_integer(IntB, fun binary_to_integer/1, Default);
to_integer(IntL, Default) when is_list(IntL) ->
  to_integer(IntL, fun list_to_integer/1, Default);
to_integer(_, Default) -> Default.

to_integer(IntT, Conv, Default) ->
  try Conv(IntT) of
    Int -> Int
  catch _:_ -> Default
  end.

to_float(Val) -> to_float(Val, 0.0).

to_float(Float, _) when is_float(Float) ->
  Float;
to_float(FloatB, Default) when is_binary(FloatB) ->
  to_float(FloatB, fun binary_to_float/1, Default);
to_float(FloatL, Default) when is_list(FloatL) ->
  to_float(FloatL, fun list_to_float/1, Default);
to_float(_, Default) -> Default.

to_float(FloatT, Conv, Default) ->
  try Conv(FloatT) of
    Float -> Float
  catch 
    error:badarg -> float(to_integer(FloatT, Default));
    _:_ -> Default
  end.

integer_or_binary(Val) ->
  case re:run(Val, "^\\d+$") of
    {match, _} -> to_integer(Val);
    _ -> Val
  end.

to_list(V) when is_list(V)    -> V;
to_list(V) when is_binary(V)  -> binary_to_list(V);
to_list(V) when is_integer(V) -> integer_to_list(V);
to_list(V) when is_float(V)   -> float_to_list(V);
to_list(V) when is_atom(V)    -> atom_to_list(V);
to_list(true)                 -> "TRUE";
to_list(false)                -> "FALSE".

to_binary(V) when is_binary(V)  -> V;
to_binary(V) when is_list(V)    -> list_to_binary(V);
to_binary(V) when is_integer(V) -> integer_to_binary(V);
to_binary(V) when is_float(V)   -> float_to_binary(V);
to_binary(V) when is_atom(V)    -> atom_to_binary(V, utf8);
to_binary(true)                 -> <<"TRUE">>;
to_binary(false)                -> <<"FALSE">>.

cleanup_map(M) when is_map(M) -> M;
cleanup_map([M])              -> cleanup_map(M).

pwd_to_db_pwd(MD5Bin) ->
  smd5(binary, <<MD5Bin/binary, (maps:get(pwd, ?CONFIG(salts, #{}), <<"deadbeef">>))/binary>>).

plain_pwd_to_db_pwd(Bin) when is_binary(Bin) ->
  plain_pwd_to_db_pwd(binary_to_list(Bin));
plain_pwd_to_db_pwd(L) ->
  pwd_to_db_pwd(smd5(binary, L)).

generate_pwd() -> generate_pwd(6, 9).
generate_pwd(MinLength, MaxLength) ->
  list_to_binary(iomod:random_str("", crypto:rand_uniform(MinLength, MaxLength), ?PWD_ABC)).

smd5(binary, S) -> list_to_binary(smd5(S));
smd5(_, S)      -> smd5(S).

smd5(S) ->
  lists:flatten([io_lib:format("~2.16.0b", [C]) || <<C>> <= erlang:md5(S)]).

random() ->
  base64:encode(crypto:strong_rand_bytes(?CONFIG(sid_size, 64))).

random_str(Prefix, 0, _) ->
  Prefix;
random_str(Prefix, Size, ABC) ->
  N = crypto:rand_uniform(1, length(ABC) + 1),
  C = lists:nth(N, ABC),
  random_str(Prefix ++ [C], Size - 1, ABC).

random_num(Min, Max) ->
  list_to_binary(lists:flatten(io_lib:format("~.10.0B", [crypto:rand_uniform(Min, Max)]))).

split(Title) ->
  case re:split(Title, " ", [{return, binary}]) of 
    [N] -> 
      {N, <<"">>};
    [N1, N2] -> 
      {N1, N2};
    L -> 
      [N2 | T] = lists:reverse(L), 
      T1 = lists:reverse(T), 
      {concat(T1, <<" ">>), N2}
  end.

concat([], _)             -> <<>>;
concat([E], _)            -> E;
concat([A1, A2 | T], Del) -> 
  concat([<<A1/binary, Del/binary, A2/binary>> | T], Del).

join(List)      -> join(List, ", ").
join(List, Sep) -> lists:concat(lists:join(Sep, List)).

floor(X) when X < 0 ->
  T = trunc(X),
  case X - T == 0 of
    true -> T;
    false -> T - 1
  end;
floor(X) -> 
  trunc(X).

ceiling(X) when X < 0 -> 
  trunc(X);
ceiling(X) ->
  T = trunc(X),
  case X - T == 0 of
    true -> T;
    false -> T + 1
  end.

take_one([H | _]) -> H.

keys_to_lower(L) ->
  [{to_lower(K), V} || {K, V} <- L].

to_lower(B) when is_binary(B) ->
  to_lower(binary_to_list(B));
to_lower(S) ->
  list_to_binary(string:to_lower(S)).

two_id_one_key(A, B) when A > B ->
  B * ?MAX_PG_INT + A;
two_id_one_key(A, B) ->
  A * ?MAX_PG_INT + B.

%
% Date utils
%

format_date_iso8601(DateTime) -> 
  iso8601:format(DateTime).

date_to_timestamp({Date, {H, M, S}}) ->
  RS = floor(S),
  calendar:datetime_to_gregorian_seconds({Date, {H, M, RS}}) - ?EPOCH + (S - RS).

timestamp_to_date(TS) ->
  RTS = floor(TS),
  {Date, {H, M, RS}} = calendar:gregorian_seconds_to_datetime(RTS + ?EPOCH),
  {Date, {H, M, RS + (TS - RTS)}}.

parse_date({{_, _, _}, {_, _, _}} = DateTime) ->
  DateTime;
parse_date(<<Y:4/binary, X, M:2/binary, X, D:2/binary>>) ->
  {{binary_to_integer(Y), binary_to_integer(M), binary_to_integer(D)}, {0,0,0}};
parse_date(Str) when is_list(Str) -> 
  parse_date(list_to_binary(Str));
parse_date(Str) -> 
  iso8601:parse(Str).

%
% hashes
%

hash(N) -> list_to_binary(hexstring(crypto:hash(sha256, N))).

hexstring(<<X:128/big-unsigned-integer>>) -> lists:flatten(io_lib:format("~32.16.0b", [X]));
hexstring(<<X:160/big-unsigned-integer>>) -> lists:flatten(io_lib:format("~40.16.0b", [X]));
hexstring(<<X:256/big-unsigned-integer>>) -> lists:flatten(io_lib:format("~64.16.0b", [X]));
hexstring(<<X:512/big-unsigned-integer>>) -> lists:flatten(io_lib:format("~128.16.0b", [X])).

%
% pubsub
%

sub(Event) -> 
  case ?IS_SUB(Event) of
    true ->
      true;
    false ->
      gproc:reg({p, l, Event})
  end.

pub(Event, Msg) ->
  gproc:send({p, l, Event}, Msg).

unsub(Event) ->
  case ?IS_SUB(Event) of
    true ->
      gproc:unreg({p, l, Event});
    false ->
      true
  end.

subs(Reg) ->
  try gproc:lookup_pids({p, l, Reg}) of
    L when is_list(L) -> 
      L;
    _ -> 
     []
  catch _:_ ->
    []
  end.

lookup(Reg) ->
  try gproc:lookup_pid({n, l, Reg}) of
    I when is_pid(I) -> 
      I;
    _ -> 
      undefined
  catch _:_ ->
    udefined
  end.

lookups(Reg) ->
  try gproc:lookup_pids({n, l, Reg}) of
    L when is_list(L) -> 
      L;
    _ -> 
     []
  catch _:_ ->
    []
  end.

%
% Cowboy request utils
%

-spec get_method(Req :: cowboy_req:req()) -> {get | post | put | delete | patch | binary(), cowboy_req:req()}.
get_method(Req) ->
  {Method, Req2} = cowboy_req:method(Req),
  {http_method_to_atom(
    list_to_binary(
      string:to_lower(
        binary_to_list(Method)))), Req2}.


-spec http_method_to_atom(Method :: binary()) -> get | post | put | delete | patch | binary();
                         (Method :: any())    -> any().
http_method_to_atom(<<"get">>)    -> get;
http_method_to_atom(<<"post">>)   -> post;
http_method_to_atom(<<"put">>)    -> put;
http_method_to_atom(<<"delete">>) -> delete;
http_method_to_atom(<<"patch">>)  -> patch;
http_method_to_atom(Metod)        -> Metod.


-spec get_request_body(Req :: cowboy_req:req()) -> {ok, binary(), cowboy_req:req()} | {error, term()}.
get_request_body(Req) ->
  get_request_body(Req, <<>>).

get_request_body(Req, Acc) ->
  case cowboy_req:body(Req) of
    {ok, Data, Req2}   -> {ok, <<Acc/binary, Data/binary>>, Req2};
    {more, Data, Req2} -> get_request_body(Req2, <<Acc/binary, Data/binary>>);
    Any                -> Any
  end.


-spec get_request_json_body(Req :: cowboy_req:req()) -> {ok, map(), cowboy_req:req()} | {error, term()}.
get_request_json_body(Req) ->
  try
    case get_request_body(Req) of
      {ok, Data, Req2} -> {ok, jsx:decode(Data, [return_maps]), Req2};
      Any              -> Any
    end
  catch 
    Exc:Exp -> 
      ?ERROR("Exception ~p:~p\n~p", [Exc, Exp, erlang:get_stacktrace()]),
      {error, wrong_body}
  end.

-spec get_request_multipart_body(cowboy_req:req()) -> {ok, map(), cowboy_req:req()} | {error, term()}.
get_request_multipart_body(Req) -> get_request_multipart_body(Req, #{}).

get_request_multipart_body(Req, Acc) ->
    case cowboy_req:part(Req) of
      {ok, Headers, Req2} ->
        case cow_multipart:form_data(Headers) of
          {data, FieldName} ->
            {ok, Value, Req3} = cowboy_req:part_body(Req2),
            get_request_multipart_body(Req3, maps:put(FieldName, Value, Acc));
          {file, FieldName, Filename, CType, CTransferEncoding} ->
            {Req3, FileBinary} = get_file(Req2),
            get_request_multipart_body(
              Req3,
               maps:put(FieldName, 
                #{
                  filename => Filename, 
                  data => FileBinary, 
                  content_type => CType, 
                  encoding => CTransferEncoding
                }, Acc))
        end;
      {done, Req2} ->
          {Req2, Acc}
    end.

get_file(Req) -> get_file(Req, <<"">>).

get_file(Req, Acc) ->
    case cowboy_req:part_body(Req) of
        {ok, Body, Req2} ->
            {Req2, <<Acc/binary, Body/binary>>};
        {more, Body, Req2} ->
            get_file(Req2, <<Acc/binary, Body/binary>>)
    end.


-spec escape_user_input(Data :: list()  ) -> binary();
                       (Data :: binary()) -> binary();
                       (Data :: any()   ) -> {error, wrong_data}.
escape_user_input(Data) when is_list(Data) ->
  escape_user_input(list_to_binary(Data));
escape_user_input(Data) when is_binary(Data) ->
  escape_user_input(Data, [
    {<<"&">>, <<"&amp;">>},
    {<<"<">>, <<"&lt;">>},
    {<<">">>, <<"&gt;">>},
    {<<"\"">>, <<"&quot;">>},
    {<<"'">>, <<"&#x27">>},
    {<<"/">>, <<"&#x2F">>}]);
escape_user_input(_Data) ->
  {error, wrong_data}.

escape_user_input(Data, []) -> Data;
escape_user_input(Data, [{Pattern, Replacement} | Chars]) ->
  escape_user_input(binary:replace(Data, Pattern, Replacement, [global]), Chars).