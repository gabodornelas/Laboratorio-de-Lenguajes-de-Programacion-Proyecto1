module Engine.Persistence (loadWorldData) where

import Data.List (find, intercalate)
import Data.Char (isPrint)
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

parseExit :: [String] -> Either String (Direction, String)
parseExit str =
  let (first, rest) = break (== "->") str
      destination = unwords (drop 1 rest)
  in case map toLower (unwords first) of
       "norte" -> Right (Norte, destination)
       "este"  -> Right (Este, destination)
       "sur"   -> Right (Sur, destination)
       "oeste" -> Right (Oeste, destination)
       _       -> Left ("Dirección inválida: " ++ unwords first)

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

findExits :: [String] -> Either String [(Direction, String)]
findExits [] = Right []
findExits e = if "SALIDA:" `elem` e then
                let (first,last) = break (== "SALIDA:") e
                in case (parseExit first) of
                        Left err -> Left err
                        Right firstParsed -> do
                            restExits <- findExits (drop 1 last)
                            Right (firstParsed : restExits)
              else
                case (parseExit e) of
                      Left err -> Left err
                      Right firstParsed -> Right [firstParsed]

------------------------------------------------------------------------------------------------------
-- Funcion que convierte un String (que viene como un elemento de una lista) y parsea su contenido
--    para crear un item
-- Los break van separando el contenido

parseItem :: String -> Either String Item
parseItem parts = case words parts of
  ("ITEM:":rest) ->
    let (nameItem, descItem) = break (== "DESC:") rest
    in if null nameItem
          then Left "Error de formato, el nombre del item no puede ser vacio"
          else if "ITEM:" `elem` descItem
                  then Left "Error de formato, no hubo buenos separadores"
                  else if null descItem
                          then Left ("Error de formato, no se define bien DESC: en -> " ++ (unwords nameItem))
                          else
                              Right Item {
                                          itemName = unwords nameItem,
                                          itemDescription = unwords (drop 1 descItem)
                                          }
  _ -> Left ("Error de formato, no se define bien ITEM: en -> " ++ (parts) ++ "\nO no se define bien SALA:")

----------------------------------------------------------------------------------------------------------
-- Funcion que convierte un String (que viene como un elemento de una lista) y parsea su contenido
--    para crear un room
-- Los break van separando el contenido por descripcion, salida, objeto

parseRoom :: [Item] -> String -> Either String Room
parseRoom mapaItems parts = case words parts of
  ("SALA:":rest) ->
    let (nameRoom, descRoom) = break (== "DESC:") rest
    in if null nameRoom
          then Left "Error de formato, el nombre de la habitacion no puede ser vacio"
          else if "SALA:" `elem` descRoom
                  then Left "Error de formato, no hubo buenos separadores"
                  else if null descRoom
                          then Left ("Error de formato, no se define bien DESC: en -> " ++ (unwords nameRoom))
                          else
                              let (fullDescRoom,exit) = break (== "SALIDA:") (drop 1 descRoom)
                              in if null exit
                                    then Left ("Error de formato, no se define bien SALIDA: en -> " ++ (unwords fullDescRoom) ++ "\nSi la habitacion no tiene salidas igual debes definir SALIDA: y dejarlo vacio")
                                    else
                                        let (allExits,allObjects) = break (== "OBJETO:") exit
                                        in if null allObjects
                                              then Left ("Error de formato, no se define bien OBJETO: en -> " ++ (unwords allExits) ++ "\nSi la habitacion no tiene objetos igual debes definir OBJETO: y dejarlo vacio")
                                              else
                                                  case (findExits (drop 1 allExits)) of
                                                        Left err -> Left err
                                                        Right exitsParsed ->
                                                            let exits = [Map.singleton dir name | (dir, name) <- (exitsParsed)] -- Convierte a Map.Map todas las tuplas de findExits
                                                                objectsNames = findObjects (drop 1 allObjects)
                                                                objects = [item | name <- objectsNames, item <- mapaItems, itemName item == name] -- Convierte la lista de nombres de item en lista de items
                                                            in if length objectsNames == length objects -- Verificamos que cada objeto asignado existe
                                                                  then Right Room { 
                                                                                  roomID = unwords nameRoom,
                                                                                  roomDescription = unwords fullDescRoom,
                                                                                  roomExits = exits,
                                                                                  roomItems = objects
                                                                                  }
                                                                  else Left ("Error de asignacion, intentas asignar objetos que no fueron definidos.\nTus objetos definidos son: " ++ (intercalate ", " (map itemName mapaItems)) ++ "\nMientras que intentas asignar: " ++ (intercalate ", " objectsNames) )
  _ -> Left ("Error de formato, no se define bien SALA: en -> " ++ (parts))

-----------------------------------------------------------------------------------------------------
-- Funcion que valida que las salas referenciadas sean salas existentes
-- toma una por una cada lista de salidas de cada sala y revisa que la sala a la que deberia salir,
-- sea una sala existente

verificaSalas :: [Room] -> [(Map.Map Direction String)] -> Either String Bool
verificaSalas rooms exits =
    case filter (`notElem` roomIDs) referencedIDs of
        []     -> Right True
        (x:_)  -> Left ("Error de asignacion, intentas asignar la sala: " ++ x ++ ", que no fue definida\nTus salas definidas son: " ++ (intercalate ", " roomIDs) )
  where
    roomIDs       = map roomID rooms
    referencedIDs = concatMap Map.elems exits

------------------------------------------------------------------------------------------------------
-- CARGA


-- Carga el archivo del mundo.
-- Devuelve (IO (Either Error (MapaDeSalas, MapaDeItems)))
loadWorldData :: FilePath -> IO (Either String (RoomContainer, ItemContainer))
loadWorldData filePath = do
  -- Leer el archivo
  world <- readFile filePath

  -- Separar items y salas
  let (items, rooms) = break (== "SALA:") (words world)
  if null rooms
    then return $ Left "Error de formato, no hay salas"
    else do
      let (goodrooms, badrooms) = break (== "ITEM:") rooms
      if not (null badrooms)
        then return $ Left "Error de formato, hay items definidos en la sección de salas"
        else do
          let elementsItems = breakElements items
              elementsRooms = breakElements rooms
          case mapM parseItem elementsItems of
              Left err        -> return $ Left err
              Right mapaItems -> do
                case mapM (parseRoom mapaItems) elementsRooms of
                    Left err        -> return $ Left err
                    Right mapaSalas -> do
                          case mapM (verificaSalas mapaSalas) (map roomExits mapaSalas) of -- Verificamos que cada sala direccionada exista
                              Left err      ->  return $ Left err
                              Right todoOk  -> do
                                    if null mapaItems || null mapaSalas
                                      then return $ Left "Error, no se crearon las salas o los items"
                                      else return $ Right (mapaSalas, mapaItems)
