# PBEM-Helper
PBEM-Helper was made to help with hosting play-by-email (PBEM) games in which a large number of files need to be transferred between players. Specifically, this was made to help with AGEOD games.

Functions:
  On its initial run, PBEM-Helper will ask for the user to input their desired zip name and the filepaths of the files to be zipped. It will remember these values on future runs. Additionally, it will count the number of times it has been run and change the name of the given zip likewise: "zip1,zip2,zip3" etc. This creates an automatic, numbered archive of turns. The config.cfg file can also be edited directly after its creation, as it is small and self-explanatory. This will allow for a better and more safely organized PBEM game. 
  
Note that for best function (unless you give absolute filepaths) the executable and config.default should live in the same folder as your files. If this causes problems, provide absolute filepaths for your zip and filepaths.
  
-planned features:
  -option to delete previous zip
  -option to use command line options to make config.cfg
  -allow absolute filepaths as opposed
  -generalization beyond AGEOD games
  -ability to check whether it will actually write a new archive, avoiding making duplicate archives with different names and     increasing the run-count by accident.
