module Engine.Parser (parseCommand) where
import Data.Char (toLower)
import Engine.Types

-- Parsea la entrada del usuario (String) a un (Maybe Command)
parseCommand :: String -> Maybe Command
parseCommand input = case words input of
  [x] | x == "mirar" -> Just Mirar
      | x == "inventario" -> Just Inventario 
      | x == "salir" -> Just Salir
  ("tomar": name) | not (null name) -> Just (Tomar (Item (unwords name) "Sin descripción"))
  ("ir": direction) | not (null direction) -> 
    case map toLower (unwords direction) of
      "norte" -> Just (Ir Norte)
      "este" -> Just (Ir Este)
      "sur" -> Just (Ir Sur)
      "oeste" -> Just (Ir Oeste)
  _ -> Nothing