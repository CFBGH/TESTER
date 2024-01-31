package lib;

class PathsList {
    public static function hitsoundList() {
        var listFile:Array<String> = [];
        var readingDir:Array<String> = FileSystem.readDirectory('assets/shared/sounds/hitsounds');
        for (i in 0...readingDir.length) {
            var output = readingDir[i].split('.');
            listFile.push(output[0]);
        }
        trace(listFile);
        return listFile;
    }
}