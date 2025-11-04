-- app/Main.hs
module Main where
import qualified Data.Map as Map
import Engine.Types
import Engine.Parser
import Engine.Core
import Engine.Persistence
import System.IO

main :: IO ()
main = do
    -- Cargar el mundo
    -- Manejar el resultado de la carga
    -- Crear el estado inicial
    -- Iniciar el bucle del juego

    -- Mundo de ejemplo. Porque hara falta Persistence. Por ahora toca directo en codigo
    -- Item inicial correcto
    let item1 = Item {
        itemName = "item1",
        itemDescription = "Item de prueba"
    }

    -- Inicial room necesita de algo, tengo problmeas aqui con
    let initialRoom = Room {
        roomId = 1,
        roomDescription = "Primer cuarto",
        roomItems = [item1],
        roomExits = Just Map.empty
    }

    -- Creacion de mapa, por dedcirlo de una forma, el grafo
    let mapa = Map.fromList [("norte", initialRoom)]

    -- Estado inicial
    let state = GameState {
        room = initialRoom,
        inventory = [item1],
        world = [initialRoom]
    }

    gameLoop state


-- El bucle principal del juego
gameLoop :: GameState -> IO ()
gameLoop state = do
    -- Parsear la entrada del usuario a un Command
    -- Si hay error, continuar con el mismo estado
    -- Procesar el comando
    -- Mostrar resultado
    -- Continuar el bucle con el nuevo estado


    putStrLn "> "
    input <- getLine
    putStrLn ("Comando introducido: " ++ input) 
    case parseCommand input of -- solo me funciono con minusculas (Correrig luego para todo tipo en Parser)
        Just dir -> do 
            putStrLn ("Direccion reconocida")
            let (mensaje, estado) = processCommand dir state
            putStrLn mensaje
        Nothing  -> putStrLn "No se reconoció la dirección"

