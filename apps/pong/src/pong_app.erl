%%%-------------------------------------------------------------------
%% @doc pong public API
%% @end
%%%-------------------------------------------------------------------

-module(pong_app).

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/1]).

%%====================================================================
%% API
%%====================================================================
-spec start() -> {ok, [atom()]} | {error, term()}.
start() ->
  {ok, _} = application:ensure_all_started(pong).

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/stats", stats_handler, []}
    ]}
  ]),
  {ok, _} = cowboy:start_http(pong, 100,
    [{port, 4001}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  bunny_client:init(),
  db:init(),
  pong_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
