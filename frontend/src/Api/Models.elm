module Api.Models exposing (..)

import Dict


type alias Response a = 
  { success : Bool
  , error : Maybe String
  , validation : Maybe (List Error)
  , data : Maybe a 
  }


type alias Error =
  { field : String
  , reason : String 
  , message : String
  , args : Maybe (Dict.Dict String String)
  }

