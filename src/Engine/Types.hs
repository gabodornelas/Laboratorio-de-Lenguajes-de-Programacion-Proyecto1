module Engine.Types where
import qualified Data.Map as Map

-- Direcciones posibles
data Direction = Norte | ESTE | OESTE | SUR -- -> Devuelve Nothing si usa con Maybe

-- Un objeto en el juego
newtype Item = Item {itemDescrition :: String} -- Por ahora solo tenemos descripcion para un objeto, nada mas

-- Una sala en el juego
data Room = Room {
      id :: Integer, -- Seria bueno supongo, para buscarlo en tal caso
      description :: String,
      roomExits :: Map.Map Direction Room, -- Asi tenemos par clave valor, para poder tener las direcciones con su room asociado
      items :: [Item]
} -- Hay que buscar la forma de que sea por referencia, para que la misma Room que se encuentra en el Map sea el que se encuentra en world

-- El estado completo del juego
data GameState = GameState {
      room :: Room,
      inventory :: [Item],
      world :: [Room] 
}

-- Comandos que el jugador puede ejecutar
data Command = Direccion | Tomar String  -- Seguramente falten mas

-- -- Placeholders para loadWorldData
-- type RoomContainer = ()
-- type ItemContainer = ()