module State exposing (..)

type alias State =
    { auth : Bool
    , token : String
    , user : User
    , context : Context
    }

type User = Anonymous | User UserInfo

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