%%%-------------------------------------------------------------------
%% @doc pong top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pong_sup).

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
    PongChildren = #{
      id => pong_subscriber,
      start => {pong_subscriber_sup, start_link, [5]},
      restart => transient,
      type => worker
    },
    {ok, { {one_for_one, 10, 60}, [PongChildren]} }.

%%====================================================================
%% Internal functions
%%====================================================================
