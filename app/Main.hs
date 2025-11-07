-- app/Main.hs
module Main where
import qualified Data.Map as Map
import Engine.Types
import Engine.Parser
import Engine.Core
import Engine.Persistence
import System.IO (hFlush, stdout)
import System.Exit (exitFailure, exitSuccess)


main :: IO ()
main = do
    -- Cargar el mundo-----------------------------------------------
    world <- loadWorldData "mundo.txt"

    -- Manejar el resultado de la carga-------------------------------
    case world of
        Left err -> do
            putStrLn ("Error de parseo: " ++ err)
            exitFailure
        Right (rooms, items) -> do
            putStrLn "El mundo se cargo con éxito"
            -- mapM_ print items
            -- mapM_ print rooms
            -- Crear el estado inicial--------------------------------
            let mapa = foldr Map.union Map.empty (roomExits (rooms !! 0))
            -- Estado inicial
            let state = GameState {
                room = rooms !! 0,
                inventory = [],
                world = rooms
            }
            
            -- Iniciar el bucle del juego-----------------------------
            gameLoop state

-- El bucle principal del juego----------------------------
gameLoop :: GameState -> IO ()
gameLoop state = do
    putStrLn ""
    putStrLn "Ingrese un comando en minusculas: mirar, ir <direccion>, tomar <objeto>, inventario, salir"
    putStr "> "
    hFlush stdout
    input <- getLine
    putStrLn ""
    case parseCommand input of 
        Just Salir -> do
            let (mensaje, estado) = processCommand Salir state
            putStrLn mensaje
            exitSuccess
        Just command -> do 
            let (mensaje, estado) = processCommand command state
            putStrLn mensaje
            gameLoop estado
        Nothing  -> do
            putStrLn "No se reconocio el comando."
            gameLoop state

