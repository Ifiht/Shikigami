module shikigami {
    requires javafx.controls;
    requires java.desktop;

    exports shikigami;
    opens shikigami to javafx.graphics;
}