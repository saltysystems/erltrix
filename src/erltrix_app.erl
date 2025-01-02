%%%-------------------------------------------------------------------
%% @doc erltrix public API
%% @end
%%%-------------------------------------------------------------------

-module(erltrix_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    erltrix_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
