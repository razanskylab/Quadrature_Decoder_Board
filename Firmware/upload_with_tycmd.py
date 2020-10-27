Import("env")

env.Replace(
    UPLOADER="C:\\Code\\TyTools\\tycmd.exe",
    UPLOADCMD="$UPLOADER upload $UPLOADERFLAGS $SOURCE"
)