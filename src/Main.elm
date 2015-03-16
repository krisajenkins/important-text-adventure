module Main where

import Signal (..)
import Html (..)
import Html.Attributes (..)
import Html.Events (..)
import String (join)
import Time (..)
import Maybe (..)
import List
import List (head,filter,(::))
import Signal
import String
import Keyboard
import Touch

adventure : List String
adventure = ["You are in a room.\nThere is tea here.\n\n> "
            ,"DRINK TEA"
            ,"\n\nYou win.\n\n\nPlay again?\n\n> "
            ,"YES"]

type Action = NoOp | Tick | Type

type alias Model =
  {content : List String
  ,line : Int
  ,column : Int}

------------------------------------------------------------

uiChannel : Channel Action
uiChannel = channel NoOp


screenView : List String -> Html
screenView s = div [class "screen well"]
                   [code []
                         [text (join "" s)
                         ,text "_"]]

sharing : Html
sharing = div [class "sharing"]
              [a [href "https://twitter.com/intent/tweet?url=https://krisajenkins.github.io/important-text-adventure/&text=Important+Text+Adventure+by+@krisajenkins"]
                 [button [class "btn btn-primary"]
                         [span [class "fa fa-twitter"] []
                         ,text " Tweet This"]]]

rootView : Model -> Html
rootView s =
  div [id "main"]
      [div [class "container"]
           [h1 [] [text "Important Text Adventure"]
           ,div [class "row"]
                [div [class "col-md-8 col-md-offset-2"]
                     [screenView (windowOnAdventure s)]]
           ,div [class "row"]
                [div [class "col-md-8 col-md-offset-2"]
                     [sharing]]]]

------------------------------------------------------------

windowOnAdventure : Model -> List String
windowOnAdventure model =
  (List.take model.line model.content)
  ++
  [String.left model.column (withDefault "" (nth model.line model.content))]

initialModel : Model
initialModel = {content = adventure
               ,line = 0
               ,column = 0}

nth : Int -> List a -> Maybe a
nth n xs =
  case (n,xs) of
    (_,[]) -> Nothing
    (0,(x::_)) -> Just x
    _ -> nth (n - 1) (List.tail xs)

isEven : Int -> Bool
isEven n = n % 2 == 0

isOdd : Int -> Bool
isOdd n = not (isEven n)

tick : (Int -> Bool) -> Model -> Model
tick f model =
  if (f model.line)
     then {model | column <- model.column + 1}
     else model

wrap : Model -> Model
wrap model =
  case nth model.line model.content of
    Nothing -> {model | line <- 0, column <- 0}
    Just string -> if String.length string < model.column
                     then wrap {model | column <- 0, line <- model.line + 1}
                     else model

step : Action -> Model -> Model
step action model =
   wrap (case action of
           NoOp -> model
           Tick -> tick isEven model
           Type -> tick isOdd model)

model : Signal Model
model = foldp step
              initialModel
              (mergeMany [subscribe uiChannel
                         ,Signal.map (\_ -> Tick) (every (75 * millisecond))
                         ,Signal.map (\_ -> Type) Keyboard.lastPressed
                         ,Signal.map (\_ -> Type) Touch.touches])

main : Signal Html
main = rootView <~ model
