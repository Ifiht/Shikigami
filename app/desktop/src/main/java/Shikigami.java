import javafx.application.Application;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

public class DesktopAppTemplate extends Application {

    @Override
    public void start(Stage primaryStage) {
        primaryStage.setTitle("Desktop App Template");

        // Top half with a static image
        ImageView imageView = new ImageView(new Image("file:static_image.png")); // Update with your image path
        imageView.setPreserveRatio(true);
        imageView.setFitHeight(200); // Adjust based on desired size

        // Bottom half for text area, text input, and button
        TextArea textArea = new TextArea();
        textArea.setWrapText(true);
        textArea.setEditable(false); // Makes text area read-only

        ScrollPane scrollPane = new ScrollPane(textArea);
        scrollPane.setFitToWidth(true);
        scrollPane.setVbarPolicy(ScrollPane.ScrollBarPolicy.ALWAYS);

        TextField inputField = new TextField();
        inputField.setPromptText("Enter your message here");

        Button sendButton = new Button("Send");
        sendButton.setOnAction(event -> {
            String userInput = inputField.getText();
            if (!userInput.isEmpty()) {
                textArea.appendText(userInput + "\n");
                inputField.clear();
            }
        });

        VBox inputBox = new VBox(5, inputField, sendButton);
        inputBox.setAlignment(Pos.CENTER);
        inputBox.setPadding(new Insets(10));

        VBox bottomBox = new VBox(5, scrollPane, inputBox);
        bottomBox.setPadding(new Insets(10));

        // Layout the top and bottom parts
        BorderPane root = new BorderPane();
        root.setTop(imageView);
        root.setCenter(bottomBox);

        // Create a scene with automatic scaling for high DPI displays
        Scene scene = new Scene(root, 600, 400);
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
