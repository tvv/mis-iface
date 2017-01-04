module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Login

main : Program (Maybe Flags) Model Msg
main =
  Html.programWithFlags
    { init = init
    , view = view
    , update = update
    , subscriptions = \_ -> Sub.none
    }

type alias Model =
  { user : Login.Model
  }

type alias Flags =
  {}

type Msg
  = LoginMsg Login.Msg

init : Maybe Flags -> ( Model, Cmd Msg )
init flags =
  ( model, Cmd.none )

model : Model
model =
  Model Login.model

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LoginMsg loginAction ->
      let
        (newUser, newMsg) =
          Login.update loginAction model.user
      in
        ( { model | user = newUser }, Cmd.map LoginMsg newMsg )

view : Model -> Html Msg
view model =
  case model.user.info of
    Login.Anonymous ->
       Html.map LoginMsg (Login.view model.user)

    Login.User userInfo ->
      view_iface model

view_iface : Model -> Html Msg
view_iface model =
  text model.user.token
