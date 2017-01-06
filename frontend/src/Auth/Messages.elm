module Auth.Messages exposing (..)

import Http
import Api.Models exposing (Response)
import Auth.Models exposing (AuthInfo)

type Msg
  = SetLogin String
  | SetPassword String
  | Login
  | Authenticated ( Result Http.Error ( Response AuthInfo ) )