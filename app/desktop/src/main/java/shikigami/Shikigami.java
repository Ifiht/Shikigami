package shikigami;

import javafx.application.Application;
import javafx.geometry.Pos;
import javafx.scene.Scene;
import javafx.scene.control.*;
import javafx.scene.control.Button;
import javafx.scene.control.ScrollPane;
import javafx.scene.control.TextArea;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.stage.Stage;

import javax.swing.*;
import java.awt.*;

public class Shikigami extends Application {

    @Override
    public void start(Stage primaryStage) {

        //=====// IMAGES & VIEWS //=====//
        Image icon = new Image(getClass().getResource("/icon.png").toExternalForm());
        Image avatar = new Image(getClass().getResource("/luka.png").toExternalForm());
        Image squareIcon = new Image(getClass().getResource("/listen.png").toExternalForm());
        Image microphoneIcon = new Image(getClass().getResource("/listen_off.png").toExternalForm());

        ImageView mainView = new ImageView(avatar); // Update with your image path
        ImageView listenIconView = new ImageView(microphoneIcon);
        Image img = mainView.getImage();
        double w = img.getWidth();
        mainView.setX((mainView.getFitWidth() - w) / 2);

        //=====// ELEMENTS AND FUNCTION //=====//
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

        // Listen ToggleButton
        ToggleButton listenButton = new ToggleButton();

        // Set the initial icon
        listenIconView.setFitWidth(20);
        listenIconView.setFitHeight(20);
        listenButton.setGraphic(listenIconView);

        // Toggle action
        listenButton.setOnAction(event -> {
            if (listenButton.isSelected()) {
                listenIconView.setImage(squareIcon); // Set to square icon
            } else {
                listenIconView.setImage(microphoneIcon); // Set to microphone icon
            }
        });

        //=====// STYLE AND PLACEMENT //=====//

        mainView.setPreserveRatio(true);
        mainView.setFitWidth(300);
        mainView.setFitHeight(300);

        inputField.getStyleClass().add("flat");
        sendButton.getStyleClass().add("flat");
        listenButton.getStyleClass().add("flat");

        // Create HBox for side-by-side arrangement of buttons
        HBox buttonBox = new HBox(10); // 10px spacing between buttons
        buttonBox.setAlignment(Pos.CENTER);
        buttonBox.getChildren().addAll(sendButton, listenButton);

        // Add all elements to root
        VBox root = new VBox(20); // 20px spacing between elements
        root.setAlignment(Pos.CENTER); // Center all elements
        root.getChildren().addAll(mainView, scrollPane, inputField, buttonBox);

        // Create a scene with automatic scaling for high DPI displays
        Scene scene = new Scene(root, 800, 600);
        scene.getStylesheets().add(getClass().getResource("/styles.css").toExternalForm());
        primaryStage.setTitle("Shikigami User Interface (ShUI)");
        primaryStage.setScene(scene);
        primaryStage.getIcons().add(icon);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
