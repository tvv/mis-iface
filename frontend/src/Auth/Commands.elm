module Auth.Commands exposing (..)

import Http
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline as Pipeline
import Api.Commands
import Auth.Models exposing (Auth, UserInfo, AuthInfo)
import Auth.Messages exposing (Msg(..))

authenticate : Auth -> Cmd Msg
authenticate {login, password} =
  let
    data = Json.Encode.object 
      [ ("login", Json.Encode.string ( Maybe.withDefault "" login ) )
      , ("password", Json.Encode.string ( Maybe.withDefault "" password ))
      ]      
  in
    Http.send Authenticated <|
      Http.post "/auth" (Http.jsonBody data ) (Api.Commands.decodeResponse decodeAuthInfo)


decodeAuthInfo : Json.Decode.Decoder AuthInfo
decodeAuthInfo =
  Pipeline.decode AuthInfo
    |> Pipeline.required "token" Json.Decode.string
    |> Pipeline.required "user" (Pipeline.decode UserInfo
      |> Pipeline.required "id" Json.Decode.int
      |> Pipeline.required "name" Json.Decode.string
      |> Pipeline.required "login" Json.Decode.string)