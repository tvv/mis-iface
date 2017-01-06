module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Auth.Update
import Routing exposing (parseLocation)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
  AuthMsg loginAction ->
    let
      ( newAuth, newUser, newMsg ) =
        Auth.Update.update loginAction model.auth model.user
    in
      ( { model | auth = newAuth, user = newUser }, Cmd.map AuthMsg newMsg )
  OnLocationChange location ->
      let
        newRoute =
          parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )
