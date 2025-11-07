module Engine.Persistence (loadWorldData) where

import qualified Data.Map as Map
import Data.Char (toLower)
import Engine.Types

----------------------------------------------------------------------------------------------------
-- Funcion que separa el string items o rooms dividiendolo en cada '---' lo que denota un nuevo
--    elemento y devuelve cada parte como elemento de una lista
-- break devuelve una tupla con fst y snd

breakElements :: [String] -> [String]
breakElements [] = []
breakElements s = (unwords (fst element)):(breakElements (drop 1 (snd element)))
  where element = break (== "---") s

--------------------------------------------------------------------------------------------------
-- Funcion que parsea cada salida a tuplas (direccion, nombre_de_sala)

parseExit :: [String] -> (Direction, String)
parseExit str =
  let (first, last) = break (== "->") str
      dir = case map toLower (unwords first) of
        "norte" -> Norte
        "este"  -> Este
        "sur"   -> Sur
        "oeste" -> Oeste
        _       -> error ("Dirección inválida: " ++ unwords first)
  in (dir, unwords (drop 1 last))

------------------------------------------------------------------------------------------------------
-- Funcion que recibe el elemento con objetos, separa cada objeto y los parsea a una lista
--    de objetos

findObjects :: [String] -> [String]
findObjects [] = []
findObjects o = if "OBJETO:" `elem` o then
                  let (first,last) = break (== "OBJETO:") o
                  in (unwords first):findObjects (drop 1 last)
                else
                  [unwords o]

---------------------------------------------------------------------------------------------------------
-- Funcion que recibe el elemento con salidas, separa cada salida y las parsea con 'parseExit'
--    a una tupla (direccion, nombre_de_sala)

findExits :: [String] -> [(Direction, String)]
findExits [] = []
findExits e = if "SALIDA:" `elem` e then
                let (first,last) = break (== "SALIDA:") e
                in (parseExit first):findExits (drop 1 last)
              else
                let (first,last) = break (== "OBJETO:") e
                in [parseExit first]

------------------------------------------------------------------------------------------------------
-- Funcion que convierte un String (que viene como un elemento de una lista) y parsea su contenido
--    para crear un item
-- Los break van separando el contenido

parseItem :: String -> Item
parseItem parts = case words parts of
  ("ITEM:":rest) ->
    let (nameItem, descItem) = break (== "DESC:") rest
    in Item {
            itemName = unwords nameItem,
            itemDescription = unwords (drop 1 descItem)
            }

----------------------------------------------------------------------------------------------------------
-- Funcion que convierte un String (que viene como un elemento de una lista) y parsea su contenido
--    para crear un room
-- Los break van separando el contenido por descripcion, salida, objeto

parseRoom :: [Item] -> String -> Room
parseRoom mapaItems parts = case words parts of
  ("SALA:":rest) ->
    let (nameRoom, descRoom) = break (== "DESC:") rest
        (fullDescRoom,exit) = break (== "SALIDA:") (drop 1 descRoom)
        (allExits,allObjects) = break (== "OBJETO:") exit
        exits = [Map.singleton dir name | (dir, name) <- (findExits (drop 1 allExits))] -- Convierte a Map.Map todas las tuplas de findExits
        objectsNames = findObjects (drop 1 allObjects)
        objects = [item | name <- objectsNames, item <- mapaItems, itemName item == name] -- Convierte la lista de nombres de item en lista de items
    in Room { 
              roomID = unwords nameRoom,
              roomDescription = unwords fullDescRoom,
              roomExits = exits,
              roomItems = objects
              }

------------------------------------------------------------------------------------------------------
-- CARGA


-- Carga el archivo del mundo.
-- Devuelve (IO (Either Error (MapaDeSalas, MapaDeItems)))
loadWorldData :: FilePath -> IO (Either String (RoomContainer, ItemContainer))
loadWorldData filePath = do
  -- Pista: usa 'readFile' para leer el archivo.
  world <- readFile filePath

  -- Luego, parsea el contenido.
  let (items, rooms) = break (== "SALA:") (words world) -- Separa el mundo en items y objetos
      elementsItems =  breakElements items  -- Separa cada elemento de los items
      elementsRooms =  breakElements rooms  -- Separa cada elemento de los rooms
      mapaItems = map parseItem elementsItems
      mapaSalas = map (parseRoom mapaItems) elementsRooms

  
  -- Si el parseo falla, devuelve (Left "Mensaje de Error")
  if null mapaItems || null mapaSalas then
    return $ Left "Mensaje de Error"
  else
    -- Si tiene exito, devuelve (Right (mapaSalas, mapaItems))
    return $ Right (mapaSalas, mapaItems)

