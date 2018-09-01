import Codec.Archive.Zip
import qualified Data.ByteString.Lazy as BL
import System.IO
import Data.Binary hiding (get)
import Data.ConfigFile
import System.Directory
import Data.Either.Utils
import qualified System.IO.Strict as S
main = do test <- doesFileExist "config.cfg"
          if (test) 
          then normalRun
          else initialRun
                    
    

type GameFiles = [FilePath]


zipper :: GameFiles -> FilePath -> IO Archive
zipper gameFiles zipFilepath = addFilesToArchive [(OptLocation zipFilepath False)] emptyArchive gameFiles


gameFilesHelper :: IO ([String],Int)
gameFilesHelper = appender [] 0
                        where appender filepaths x = do
                                putStrLn "Enter the filepath for a trn or hst file. Enter q when all all files have been collected"
                                filepath <- getLine
                                if filepath == "q"
                                    then return (filepaths,x)
                                    else appender ([filepath] ++ filepaths) (x + 1)
                               
initialRun = do   --sets up and writes the config file--
                    --gets the user inputted values
                  cpm <- readfile emptyCP "config.default"
                  let cp = forceEither cpm
                  putStrLn "Zip name? (do not include file extension)"
                  name <- getLine
                    --modifies the config file, then writes it to the filesystem--
                  --let zipPath = gameDirectory ++ name ++ "1.zip"
                  fpint <- gameFilesHelper
                  let filepaths = fst fpint
                  let filepathCount = snd fpint
                  let modifiedConfig = setFilePathList filepaths filepathCount cp
                        where setFilePathList xs 0 cf = cf
                              setFilePathList (x:xs) y cf = setFilePathList xs (y - 1) newcf
                                                            where newcf = forceEither $ set cf "DEFAULT" ("filepath_" ++ (show y)) x
                  let finalConfig = set (forceEither $ set modifiedConfig "DEFAULT" "run_count" "1") "DEFAULT" "zip_name" name
                  let stringedConfig = to_string $ forceEither finalConfig
                  writeFile "config.cfg" stringedConfig                                                
                                                                                   
                  --encodes and writes the archive-- 
                  archive <- zipper filepaths name
                  let zippedArchive = encode archive
                  BL.writeFile name zippedArchive
                  
                  
normalRun = do    --loads up the config and creates the necessary variables for the zip to be made--
                  cfe <- readfile emptyCP "config.cfg"
                  let cf = forceEither cfe
                  let zipTempName  = forceEither $ get cf "DEFAULT" "zip_name"
                  let runCount     = forceEither $ get cf "DEFAULT" "run_count"
                  let zipName      = zipTempName ++ runCount
                  let filepathList = helper cf "filepath_" 1 []
                        where helper _ _ 7 fps   = fps
                              helper cf os x fps = if ((forceEither $ get cf "DEFAULT" (os ++ (show x))) == "default")
                                                        then fps
                                                        else helper cf os (x+1) newfps
                                                            where newfps = (fps ++ [partfps])
                                                                    where partfps = (forceEither $ get cf "DEFAULT" (os ++ (show x)))
                  
                  archive <- zipper filepathList zipName
                  let zippedArchive = encode archive
                  BL.writeFile zipName zippedArchive
                  --updates the config for the next run--
                  let modifiedConfig = forceEither $ set cf "DEFAULT" "run_count" (show $ read runCount + 1)
                  let stringedConfig = to_string $ modifiedConfig
                  writeFile "config.cfg" stringedConfig

                  
              

