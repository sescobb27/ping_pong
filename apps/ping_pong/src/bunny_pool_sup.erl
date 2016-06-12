-module (bunny_pool_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  Children1 = poolboy:child_spec(bunny_ping_pool, [
      {name, {local, bunny_ping_pool}},
      {size, 50},
      {max_overflow, 20},
      {worker_module, bunny_worker}
    ], []),
  Children2 = poolboy:child_spec(bunny_pong_pool, [
    {name, {local, bunny_pong_pool}},
    {size, 50},
    {max_overflow, 20},
    {worker_module, bunny_worker}
  ], []),
  {ok, { {one_for_one, 10, 10}, [Children1, Children2]} }.

%%====================================================================
%% Internal functions
%%====================================================================
