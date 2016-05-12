%%%-------------------------------------------------------------------
%% @doc ping public API
%% @end
%%%-------------------------------------------------------------------

-module(ping_app).

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/1]).

%%====================================================================
%% API
%%====================================================================
-spec start() -> {ok, [atom()]} | {error, term()}.
start() ->
  {ok, _} = application:ensure_all_started(ping).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
      {'_', [
        {"/ping", ping_handler, []}
      ]}
    ]),
    {ok, _} = cowboy:start_http(ping, 100,
      [{port, 4000}],
      [{env, [{dispatch, Dispatch}]}]
    ),
    ping_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
