# Trackosome
A computational toolbox to study the spatiotemporal dynamics of centrosomes, nuclear envelope and cellular membrane 

Domingos Castro, Vanessa Nunes, Joana T. Lima, Jorge G. Ferreira,  Paulo Aguiar

doi: https://doi.org/10.1101/2020.04.27.064204


Trackosome, is a freely available computational tool to track the centrosomes and reconstruct the nuclear and cellular membranes, based on volumetric live-imaging data. The toolbox runs in MATLAB and provides a graphical user interface for easy and efficient access to the tracking and analysis algorithms. It outputs key metrics describing the spatiotemporal relations between centrosomes, nucleus and cellular membrane. Trackosome can also be used to measure the dynamic fluctuations of the nuclear envelope. Unlike previous algorithms based on circular/elliptical approximations of the nucleus, Trackosome measures membrane movement in a model-free condition, making it viable for irregularly shaped nuclei. Overall, Trackosome is a powerful tool to help unravel new elements in the spatiotemporal dynamics of subcellular structures.


Trackosome is composed of 3 main modules:
- Centrosome Dynamics
- Membrane Fluctuations
- Compile Data



To run Trackosome:

1 - Open MATLAB

2 - Change the MATLAB's working directory to where you have the Trackosome files

3 - In MATLAB's command window run the GUI command (GUI_Main_Menu, GUI_FLUCT_Main_menu, or GUI_Compile_Data) of the component you want to use



For help, please check the demostration video: Demo_HowToVideo.mp4



If you use this software in your research please acknowledge TRACKOSOME preprint in bioRxiv: Castro D, Nunes V, Lima J, Ferreira J, Aguiar P "A computational toolbox to study the spatiotemporal dynamics of centrosomes, nuclear envelope and cellular membrane", doi: https://doi.org/10.1101/2020.04.27.064204


For questions, suggestions, and bug reports send an email to pauloaguiar@ineb.up.pt

TRACKOSOME uses BioFormats, an incredible tool provided by The Open Microscopy Environment innitiative
https://www.openmicroscopy.org/


!!! Always check for a new version of TRACKOSOME at: https://github.com/Trackosome !!!


Thank you for using TRACKOSOME!


THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
