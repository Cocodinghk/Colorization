# Colorization

## Environment

- Matlab R2020a

## How to run

- **Colorize the image:** Modify the pictures in folder "/src/data" and edit the correct loaction in run_me.m, then run **run_me.m**.

- **Command prompt:** You will see three Matlab figures. The first contains the input image. You can click on the mouse in this figure to mark points that define a scribble and then press **'c'** to choose a color for the scribble. You choose a color by clicking in figure 3 on the color chooser. If the input image is a color image, you can press **'d'** to have the color of the scribble be defined by the colors in the original image. Pressing **'a'** will run the multigrid algorithm and display results in figure 2. Pressing **'A'** will run the direct solver.

- **Colorize user-defined image:**  If you prefer to use your favorite image editing program (e.g. Photoshop, gimp) you need to save two images to the disk.

  1) The original B/W image. The image needs to be saved in an RGB (3 channels) format.
  2) The B/W with colors scribbled in the desired places. Use your favorite paint program (Photoshop, paint, gimp and each) to generate the scribbles. Make sure no compression is used and the only pixels in which the RGB value of the scribbled image are different then the original image are the colored pixels.

  To run the program define the desired solver and the input file names in the head of the 'colorize.m' file. Then just call the 'colorize' script from within matlab.
