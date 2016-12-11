module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Login


main : Program (Maybe Flags) State Action
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias State =
    { auth : Bool
    , token : String
    , user : User
    , context : Context
    }


type User
    = Anonymous
    | User UserInfo


type alias UserInfo =
    { id : Int
    , name : String
    , login : String
    }


type alias Context =
    { login : Login.State
    }


type alias Flags =
    {}


type Action
    = Login Login.Action


init : Maybe Flags -> ( State, Cmd Action )
init flags =
    ( state, Cmd.none )


state : State
state =
    { auth = False
    , token = ""
    , user = Anonymous
    , context =
        { login = Login.state
        }
    }


update : Action -> State -> ( State, Cmd Action )
update action ({ context } as state) =
    case action of
        Login loginAction ->
            let
                newContext =
                    Login.update loginAction context.login
            in
                ( { state | context = { context | login = newContext } }, Cmd.none )


view : State -> Html Action
view state =
    case state.user of
        Anonymous ->
           Html.map Login (Login.view state.context.login)

        User userInfo ->
            view_iface state


view_iface : State -> Html Action
view_iface state =
    div [] []
