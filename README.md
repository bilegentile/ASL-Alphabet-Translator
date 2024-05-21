# ASL Alphabet Translator
This is an app that translates from a live camera input the ASL Alphabet poses to text.

This is a macOS app project that i did to learn more about the CreateML, AVFoundation and Vision frameworks in SwiftUI.

I think that communication should be for all, that's why I decided to start this project, to help people learn the ASL language!
From this I also started learning my first letters.
You will get fromt the application instant feedbacks about the accuracy of your poses.

Machine Learning can be a powerful tool to break barriers between people!

## Screenshots
| **A Letter** | **S Letter** | **L Letter** |
|:---:|:---:|:---:|
|![A](https://github.com/bilegentile/ASL-Alphabet-Translator/blob/main/screenshots/A_screen.png) |![S](https://github.com/bilegentile/ASL-Alphabet-Translator/blob/main/screenshots/S_Letter.png) |![L](https://github.com/bilegentile/ASL-Alphabet-Translator/blob/main/screenshots/L_screen.png) |

## Process
First of all, I used a dataset of images in CreateML to build a Hand Pose Classifier. It took 7 hours and 30 minutes on an M2 Pro chip with 16GB of RAM to create the model, starting from a 1GB dataset (more about the dataset in the Acknowledgements section).

Then, I started implementing the Live Camera in SwiftUI trought AVFoundation.

And finally, I used the Vision framework to connect the camera and model and display the result.

## Future implementations
CreateML not only can make models on poses, but also on actions. So, with a dataset of videos is possible to implement actual words in the application, this would be a starting point for a real ASL translator!

The UX/UI is just a test for now, in the future it will be implemented a more user-friendly interface.


## Acknowledgements

 - [ASL Alphabet dataset from Kaggle](https://www.kaggle.com/datasets/grassknoted/asl-alphabet)

