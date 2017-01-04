module Api exposing (..)

import Http
import Json.Encode
import Json.Decode
import Json.Decode.Pipeline

type alias Response a = 
  { success: Bool
  , error: Maybe String
  , validation: Maybe (List Error)
  , data: Maybe a }

type alias Error =
  { field: String
  , reason: String }

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

encodeResponse : (a -> Json.Encode.Value) -> Response a -> Json.Encode.Value
encodeResponse encodeData record =
  Json.Encode.object
    [ ("success",  Json.Encode.bool record.success)
    , ("error",  encodeMaybe Json.Encode.string record.error)
    , ("validation",  encodeMaybe (\v -> Json.Encode.list <| List.map encodeValidation v) record.validation)
    , ("data",  encodeMaybe encodeData record.data)
    ]

encodeValidation : Error -> Json.Encode.Value
encodeValidation record =
  Json.Encode.object
    [ ("field",  Json.Encode.string <| record.field)
    , ("reason",  Json.Encode.string <| record.reason)
    ]

encodeMaybe : (a -> Json.Encode.Value) -> Maybe a -> Json.Encode.Value
encodeMaybe encoder data =
  case data of
    Just v -> encoder v
    _      -> Json.Encode.null