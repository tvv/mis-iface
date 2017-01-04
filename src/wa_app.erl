-module(wa_app).
-behaviour(application).

-export([
        start/2, 
        stop/1,
        priv_dir/0,
        compile_templates/0
    ]).

-include("include/wa.hrl").

start(_StartType, _StartArgs) ->
  application:ensure_all_started(lager),
  Priv = priv_dir(),
  VRoutes = static_routes(Priv) ++ [
      {"/", cowboy_static, {file,  filename:join([Priv, "index.html"])}},
      {"/[...]", default_handler, []}
    ],
  Dispatch = cowboy_router:compile([{'_',  VRoutes}]),
  compile_templates(Priv),
  cowboy:start_http(webapp_http_listener, 5, 
                    [{port, 8080}],
                    [
                      {env, [{dispatch, Dispatch}]}
                    ]),
  wa_sup:start_link().

stop(_State) ->
  ok.

root_dir() ->
  Ebin = filename:dirname(code:which(?MODULE)),
  filename:dirname(Ebin).

priv_dir() ->
  filename:join(root_dir(), "priv").


static_routes(Priv) ->
  lists:map(fun(I) ->
    {"/" ++ I ++ "/[...]", cowboy_static, {dir,  filename:join([Priv, I])}}
  end, ["css", "js", "i", "audio"]).

compile_templates() ->
  compile_templates(priv_dir()).

compile_templates(Priv) ->
  Options = [
    {force_recompile, true},
    {auto_escape, false}
  ],
  R = lists:map(fun(Dir) ->
      {ok, Files} = file:list_dir(Dir),
      ValidFiles = lists:filter(fun(I) -> filename:extension(I) =:= ".dtl" end, Files),
      lists:map(fun(F) ->
        FilePath = filename:join(Dir, F),
        TplName = list_to_atom(re:replace(F, "\\.", "_", [{return, list}])),
        {FilePath, erlydtl:compile_file(FilePath, TplName, Options)}
      end, ValidFiles)
    end, [
          filename:join([Priv, "templates"])
    ]),
  ?INFO("Compiled ~p~n", [R]),
  R.