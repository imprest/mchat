-module(mchat_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    application:start(mchat).

start(_StartType, _StartArgs) ->
	application:start(crypto), 
	application:start(ranch),
	application:start(cowboy),

	Dispatch = [{'_', [{[<<"mchat-api">>], bullet_handler, 
                        [{handler, mchat_ws_handler}]},
                       {[<<"upload">>], bullet_handler, 
                        [{handler, mchat_upload_handler}]},
                       {[<<"download">>], bullet_handler, 
                        [{handler, mchat_download_handler}]},
                       {[], cowboy_static,
                        [{directory, {priv_dir, ?MODULE, [<<"mchat">>]}},
                         {file, <<"index.html">>},
                         {mimetypes, [{<<".html">>, [<<"text/html">>]}]}]},
                       {['...'], cowboy_static,
                        [{directory, {priv_dir, ?MODULE, [<<"mchat">>]}},
                         {mimetypes,
                          [{<<".css">> , [<<"text/css">>]},
                           {<<".png">> , [<<"image/png">>]},
                           {<<".jpg">> , [<<"image/jpeg">>]},
                           {<<".jpeg">>, [<<"image/jpeg">>]},
                           {<<".js">>  , [<<"application/javascript">>]}]}]}
                      ]}
               ],
    Port = mchat_utils:confval(mchat, port, 8080),
    WSPool = mchat_utils:confval(mchat, ws_pool_size, 100),
    cowboy:start_http(http, WSPool, [{port, Port}], [{env, [{dispatch, Dispatch}]}]),

    mchat_sup:start_link().

stop(_State) ->
    ok.
