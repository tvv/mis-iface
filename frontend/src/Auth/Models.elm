module Auth.Models exposing (..)


type alias Auth =
  { token: Maybe String
  , login : Maybe String
  , password : Maybe String
  , error: Maybe String
  , loading: Bool
  }


type User 
  = Anonymous
  | User UserInfo


type alias UserInfo =
  { id : Int
  , name : String
  , login : String
  }


type alias AuthInfo =
  { token : String
  , user : UserInfo
  }


initialAuthModel : Auth
initialAuthModel =
  { token = Nothing
  , login = Nothing
  , password = Nothing
  , error = Nothing
  , loading = False
  }


initialUserModel : User
initialUserModel = 
  Anonymous