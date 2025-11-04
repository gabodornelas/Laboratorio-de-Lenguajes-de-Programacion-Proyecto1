module Engine.Core (processCommand) where

import Engine.Types

-- La función PURA que actualiza el estado del juego
processCommand :: Command -> GameState -> (String, GameState)
processCommand command state = case command of
  Mirar -> ("El persona Miro", state)
  -- Pista: usar pattern matching para manejar cada comando (Ir, Tomar, Mirar, etc.)
  -- Devuelve siempre una tupla de (Mensaje para el usuario, NuevoEstado)
  -- Blanyer: Considero que hay que hacer primer un case para determianr que tipo de comando se esta pasando, y realizar la accion a consecuencia