module Engine.Core (processCommand) where

import qualified Data.Map as Map
import Data.List (find, intercalate)
import Engine.Types

processCommand :: Command -> GameState -> (String, GameState)

processCommand Mirar state =
  let currentRoom = room state
      items = roomItems currentRoom
      roomName = roomID currentRoom
      desc = roomDescription currentRoom
      exitsList = roomExits currentRoom
      fullMap = foldr Map.union Map.empty exitsList
      dirs = Map.keys fullMap
      itemsMsg = if null items then "(ninguno)" else intercalate ", " (map itemName items)
      msg = unlines ["Sala: " ++ roomName,
                     "Descripcion: " ++ desc,
                     "Objetos: " ++ itemsMsg]
  in (msg, state)

processCommand (Tomar objeto) state =
  let currentRoom = room state
      items = roomItems currentRoom
      itemFound = find (\item -> itemName item == itemName objeto) items
  in case itemFound of
       Nothing -> ("No encontraste ese objeto en la sala.", state)
       Just found ->
         let -- Remover el objeto tomado de la sala
             newRoom = currentRoom { roomItems = filter (\removeItem -> itemName removeItem /= itemName found) items }
             newInventory = found : inventory state
             -- Remplazar la sala por la nueva versión en el world
             newWorld = map (\changeRoom -> if roomID changeRoom == roomID currentRoom then newRoom else changeRoom) (world state)
             newState = state { room = newRoom, inventory = newInventory, world = newWorld }
         in ("Has tomado: " ++ itemName found, newState)

processCommand (Ir direction) state =
  let currentRoom = room state
      exitsList = roomExits currentRoom 
      fullMap = foldr Map.union Map.empty exitsList
      moveRoom = Map.lookup direction fullMap
  in case moveRoom of
       Nothing -> ("No hay encontraste salida en esa dirección.", state)
       Just destRoom -> -- Actualizar el estado con la nueva sala
         let newState = state { room = destRoom }
         in ("Te diriges hacia: " ++ roomID destRoom ++ " - " ++ roomDescription destRoom, newState)

processCommand Inventario state =
  let inv = inventory state
      itemsMsg = if null inv then "(ninguno)" else intercalate ", " (map itemName inv)
      msg = if null inv
              then "Inventario vacío."
              else "Inventario: " ++ itemsMsg
  in (msg, state)

processCommand Salir state = ("Saliendo...", state)