module Engine.Types where
import qualified Data.Map as Map

-- Direcciones posibles
data Direction = Norte | Este | Oeste | Sur -- -> Devuelve Nothing si usa con Maybe

-- Un objeto en el juego
data Item = Item {
      itemName :: String,
      itemDescription :: String
}

-- Una sala en el juego
data Room = Room {
      roomId :: Integer, -- Seria bueno supongo, para buscarlo en tal caso
      roomDescription :: String,
      roomExits :: Maybe (Map.Map Direction Room), -- Asi tenemos par clave valor, para poder tener las direcciones con su room asociad. Coloque Maybe para probar en el main
      roomItems :: [Item]
} -- Hay que buscar la forma de que sea por referencia, para que la misma Room que se encuentra en el Map sea el que se encuentra en world

-- El estado completo del juego
data GameState = GameState {
      room :: Room,
      inventory :: [Item],
      world :: [Room] 
}

-- Comandos que el jugador puede ejecutar
data Command -- Hay que tomar en cuenta unas variantes ligeras que salen en el enunciado
      = Ir Direction
      | Mirar
      | Tomar Item
      | Inventario
      | Salir

-- Placeholders para loadWorldData
type RoomName = ()
type ItemName = ()