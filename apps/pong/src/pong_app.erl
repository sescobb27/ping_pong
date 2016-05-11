%%%-------------------------------------------------------------------
%% @doc pong public API
%% @end
%%%-------------------------------------------------------------------

-module(pong_app).

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/1, start_phase/3]).

%%====================================================================
%% API
%%====================================================================
-spec start() -> {ok, [atom()]} | {error, term()}.
start() ->
  {ok, _} = application:ensure_all_started(pong).

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {'_', [
      {"/pong", pong_handler, []},
      {"/stats", stats_handler, []}
    ]}
  ]),
  {ok, _} = cowboy:start_http(pong, 100,
    [{port, 4001}],
    [{env, [{dispatch, Dispatch}]}]
  ),
  pong_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
start_phase(create_kafka_client, _StartType, []) ->
  kafka_client:init(pong_client),
  kafka_client:init_producer(pong_client, <<"pong">>).
