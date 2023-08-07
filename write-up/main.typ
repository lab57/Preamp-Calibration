#import "template.typ": *

// Take a look at the file `template.typ` in the file panel
// to customize this template and discover how it works.
#show: project.with(
  title: "Lab 28 Signal Processing",
  authors: (
    (name: "Luc Barrett", email: "labarrett@umass.edu", affiliation: "Kumar Lab 028"),
  ),
  date: datetime.today().display("[month repr:long] [day], [year]"),
)

#show link: underline

#set heading(numbering: "1.1")
#outline()
#pagebreak()



= Charge Sensitive Preamplifier

== Function & Purpose
A Charge Sensitive Preamplifier (CSP) is a device used for detecting electrical pulses from detectors.  A CSP can take in a pulse of current, and in its most basic form, the result is proportional to the integral of charge passing through
#align(center, 
grid(
  columns: 2, rows: 1,
figure(image("SimpleCircuit.jpg", height: 20%), caption: [Simplified circuit diagram]),
figure(
  image("CSP_pulses.jpg", width: 50%), caption: [Detector pulse and resulting signal from CSP]
)
))
This is generally useful as some types of detectors, for example a PMT, may release a small burst of electrons (comparable to a delta function spike in current), which is much harder to measure than a voltage difference.

This circuit arrangement is generally problematic, as multiple pulses will keep causing an increase to an unbounded size. This can be resolved by adding a bleed resistor

#figure(image("bleed.jpg", height: 20%), caption: [More typical circuit digram including the bleed resistor $R_f$])

#figure(image("taildecay.jpg", height: 30%), caption: [Resulting pulse from introducing the bleed resistor])

This pulse will decay with a time constant of $tau = C_f R_f$. It is not depdendant on any other properties of the pulse, though a slow rise time will affect the overall shape.

== Calibration

To know the gain of the CSP, we must inject it with a current pulse with a known charge. To do so, a capacitor can be placed in series with a function generator producing a square wave. Then, when there is a change in voltage, the amount of charge injected is
$ Q = C_f Delta V$ (discussed more in the next section). In the evaluation boards, there is one of these capacitors with $C_f=1 "pF"$ already in the test input.

It is not generally nessecary to calibrate the preamp on it's own, as it will generally be used in series with a shaper.

#figure(image("DS0052.png", height: 30%), caption: [View from oscilloscope of function generator signal (yellow), preamp (blue), and shaper (pink). The pulse width of the shaper is so small it is difficult to see in this image; Refer to @osc-zoomed])




= Shaper
== Introduction and Purpose
The CR-200 is a Gaussian shaping amplifier module, and is used to read out the “tail pulse” signals such as from charge sensitive preamplifiers, PMTs, and other similar detection circuits. Gaussian shaping amplifiers are also known as 'pulse amplifiers', 'linear amplifiers', or 'spectroscopy amplifiers' in the general literature. They accept a step-like input pulse and produce an output pulse shaped like a Gaussian function (bell curve). The purpose of these amplifiers is not only to transform the shape of the event pulse from a tail pulse to a bell curve, but also to filter much of the noise from the signal of interest. Use of shaping amplifiers will reduce the fall time of the pulse signals, reducing the incidence of pulse 'pile up', and improve the signal-to-noise of the detection system.

#figure(
  image("shaper_func.jpg", width: 70%),
  caption: [Response of shaper unit]
)

The shaping time is defined as the time-equivalent of the "standard deviation" of the Gaussian output pulse. A simpler measurement to make in the laboratory is the full width of the pulse at half of it's maximum value (FWHM). This value is greater than the shaping time by a factor of 2.4. For example, a Gaussian shaping amplifier with a shaping time of 1.0 $mu s$ would have a FWHM of 2.4 $mu s$.


#figure(image("DS0053.png", height: 40%), caption: [View from oscilliscope, with same color coorrespondance as before. The view is zoomed in to make the signal of the shaper clear])<osc-zoomed>


== Calibration
The shaper has it's own gain that can be adjusted with controls on the front of the device. There is a fine gain along with two switches that can be toggled. Per the specification document, each switch adds a gain of a factor of 10. This gain factor was measured and at worst found to be 9.94.

#figure(
  image("0.2.png", width: 60%),
  caption: [Typical fit to a shaper signal. $A = 0.197 plus.minus .0001 "V ", sigma =52 "ns"$]
)
$ f(x) = A e^(-1/2 (x - mu)^2/sigma^2 ) + c $
Since the resulting output signal of the shaper is approximately gaussian, a calibration with uncertainty can be performed by injecting an input charge (calculated with the $C_f$ from the preamp and a square wave as described) and doing a gaussian fit to the output signal and extracting the amplitude $A$. This is generally an easier way to get good data than calibrating both individually, so each particular "stack" (particular preamp and shaper unit) should be calibrated together. The calibration should be done with the oscilloscope set to 1M$ohm$ impedance since that's the imedance of the digital oscilloscope that will be used for taking data.



== Jumper Wire
In the absense of a CR-200X module, as in our case, a jumper wire had to be installed that was previously missing. This was done according to the documentation of the unit. If a 200X module is added in the future this will need to be removed.

#pagebreak()
= Calibration Data
Code used to perform calibration available on Github #link("https://github.com/lab57/Preamp-Calibration")


Note that if the fine gain is tweaked on the shaper, this will need to be performed again.
== Preamp 1 $->$ Shaper 1

#figure(
  image("../final_fit.png", width: 75%),
  caption: [Fit to the response of the shaper and preamp combination]
)

This data was taken with preamp-1 and shaper-1, the shaper having both gain switches off. The resulting calibration value is 
$ 3.85 plus.minus .02 "V/pC" $ Additionally note that this does not take into accounnt the resistance in the wire from the function generator to the preamp, but this is likely a very small effect. The data range taken is over the maximimum possible range, going from the minimum voltage difference of the function generator (50 mV) until the response became no longer linear (\~2V)