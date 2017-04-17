import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput,onClick)
import Http
import Json.Decode as Decode


main =
  Html.program
    { init = init "foo"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



  
-- MODEL


type alias Model =
  { username : String
  , password : String
  , captcha : String
  , message : String
  }


model : Model
model =
  Model "" "" "" ""
  
init : String -> (Model, Cmd Msg)
init topic =
  ( model
  , Cmd.none
  )


-- UPDATE


type Msg
    = Username String
    | Password String
    | Captcha String
    | Login 
    | OnLoginResult (Result Http.Error String)

--TODO 用户名必填
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Username name ->
      ({ model | username = name },Cmd.none)

    Password password ->
      ({ model | password = password },Cmd.none)

    Captcha captcha ->
      ({ model | captcha = captcha },Cmd.none)
      
    Login ->
      ({model | message = "处理中"},loginCheck model)
    
    OnLoginResult(Ok msg) ->
      ({model | message = msg},Cmd.none)
    OnLoginResult(Err _) ->
      ({model | message = "异常"},Cmd.none)
      

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- VIEW


view : Model -> Html Msg
view model =
  div [ style [("margin","5em") ] ]
    [
      h1 [] [text "请登录" ] 
    , input [ type_ "text", placeholder "用户名", onInput Username ] []
    , br [] []
    , input [ type_ "password", placeholder "密码", onInput Password ] []
    , br [] []
    , input [ type_ "text", placeholder "验证码", onInput Captcha ] []
    , br [] []
    , button [ onClick Login ] [text "登录"]
    , br [] []
    , div [] [text(model.username++","++model.password++","++model.captcha++model.message)]
    ]

-- net
loginCheck : Model -> Cmd Msg
loginCheck model =
  let 
    url = "login.json?username="++model.username
  in
    Http.send OnLoginResult (Http.get url decodeJson)
    
decodeJson : Decode.Decoder String
decodeJson = 
  Decode.at ["payload", "username"] Decode.string
