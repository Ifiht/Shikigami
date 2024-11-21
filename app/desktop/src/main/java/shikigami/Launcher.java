package shikigami;



public class Launcher {
    public static void main(String[] args) {
        // do NOT extend application, prevents us from creating a fat jar..
        Shikigami.main(args);
    }
}