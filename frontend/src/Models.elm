module Models exposing (..)

import Auth.Models
--import Menu.Models
import Routing


type alias Model =
  { auth : Auth.Models.Auth
  , user : Auth.Models.User
--  , menu : Menu.Models.Model
  , route : Routing.Route
  }


initialModel : Routing.Route -> Model
initialModel route =
    { auth = Auth.Models.initialAuthModel
    , user = Auth.Models.initialUserModel
--    , menu = Menu.Models.initialModel
    , route = route
    }