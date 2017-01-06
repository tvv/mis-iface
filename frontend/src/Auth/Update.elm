module Auth.Update exposing (..)

import Navigation
import Api.Models exposing (Response)
import Auth.Messages exposing (Msg(..))
import Auth.Models exposing (Auth, User(..), AuthInfo)
import Auth.Commands as Commands


update : Msg -> Auth -> User -> ( Auth, User, Cmd Msg )
update msg auth user =
  case msg of
    SetLogin newLogin ->
      ( { auth | login = Just newLogin, error = Nothing }, Anonymous, Cmd.none )

    SetPassword newPassword ->
      ( { auth | password = Just newPassword, error = Nothing }, Anonymous, Cmd.none )

    Login ->
      if empty auth.login || empty auth.password then
        ( { auth | error = Just "Empty cridentials" }, Anonymous, Cmd.none )
      else
        ( { auth | token = Nothing, error = Nothing, loading = True }, Anonymous , Commands.authenticate auth )

    Authenticated ( Ok response ) ->
      authenticate response auth user

    Authenticated ( Err _ ) ->
      ( { auth | token = Nothing, error = Just "Something gone wrong", loading = False }, Anonymous, Cmd.none )


empty : Maybe String -> Bool
empty val =
  case val of
    Nothing -> True
    Just "" -> True
    _ -> False


authenticate : Response AuthInfo -> Auth -> User -> ( Auth, User, Cmd Msg )
authenticate response auth user =
  let 
    newAuth = { auth | loading = False }
  in 
    case response.data of
      Just auth ->
        ( { newAuth | token = Just auth.token, error = Nothing, login = Nothing, password = Nothing }, User auth.user, Navigation.newUrl "#/dashboard" )
      Nothing ->
        ( { newAuth | token = Nothing, error = Just (Maybe.withDefault "Unknown error" response.error) }, Anonymous, Cmd.none )