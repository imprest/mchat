
-module(mchat_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    WSServerSpec = ?CHILD(mchat_server, worker),
    ChildSpecs = [WSServerSpec],
    RestartStrategy = {one_for_all, 3, 30},
    {ok, {RestartStrategy, ChildSpecs}}.

