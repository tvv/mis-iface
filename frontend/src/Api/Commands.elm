module Api.Commands exposing (..)

import Http
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline
import Api.Models exposing (Response, Error)


decodeResponse : Json.Decode.Decoder a -> Json.Decode.Decoder (Response a)
decodeResponse decodeData =
  Json.Decode.Pipeline.decode Response
    |> Json.Decode.Pipeline.required "success" (Json.Decode.bool)
    |> Json.Decode.Pipeline.optional "error" (Json.Decode.maybe Json.Decode.string) Nothing
    |> Json.Decode.Pipeline.optional "validation" (Json.Decode.maybe <| Json.Decode.list decodeError) Nothing
    |> Json.Decode.Pipeline.optional "data" (Json.Decode.maybe decodeData) Nothing


decodeError : Json.Decode.Decoder Error
decodeError =
  Json.Decode.Pipeline.decode Error
    |> Json.Decode.Pipeline.required "field" (Json.Decode.string)
    |> Json.Decode.Pipeline.required "reason" (Json.Decode.string)
    |> Json.Decode.Pipeline.required "message" (Json.Decode.string)
    |> Json.Decode.Pipeline.optional "args" (Json.Decode.dict Json.Decode.string 
      |> Json.Decode.maybe) Nothing