import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from scipy.optimize import curve_fit
from scipy.stats import norm
from dataclasses import dataclass
from uncertainties import ufloat
import uncertainties


@dataclass
class FitInfo:
    mu: float
    std: float
    A: float
    c: float
    mu_err: float
    std_err: float
    A_err: float
    c_err: float

    def params(self):
        return [self.mu, self.std, self.A, self.c]

    def __repr__(self):
        return f"""FitInfo(
mu: {self.mu:0.4g} +- {self.mu_err:.1g}
std: {self.std:0.4g} +- {self.std_err:.1g}
A: {self.A:0.4g} +- {self.A_err:.1g}
c: {self.c:0.4g} +- {self.c_err:.1g}
)"""


def loadFile(name: str) -> tuple[list[float], list[float]]:
    """Load the time (t) and voltage (V) from a file, formatted as output from oscilloscope

    Args:
        name (str): File name/path

    Returns:
        tuple[float, float]: tuple of (time data, voltage data)
    """
    t, v = np.loadtxt(
        f"./data/{name}", skiprows=17, delimiter=",", usecols=(0, 1), unpack=True
    )
    return t, v


def gauss(x, mu, std, A, c):
    """
    Gaussian function
    """
    return A * np.exp(-1 / 2 * (x - mu) ** 2 / std**2) + c


def fitGaus(t: list[float], V: list[float]) -> FitInfo:
    """Fit to normal distribution

    Args:
        t (list[float]): time data
        V (list[float]): voltage data

    Returns:
        FitInfo: FitInfo class containing all parameters and uncertainties
    """

    # gaus = lambda x, mu, std, A, c : c+A*norm.pdf(x,mu, std)
    p, cov = curve_fit(
        gauss,
        t,
        V,
        p0=(0.1e-6, 0.1e-6, 0, 1),
    )
    return FitInfo(*p, *np.sqrt(np.diag(cov)))


def getFits(rng: tuple[int, int], plot=False) -> list[FitInfo]:
    fitResults = []
    for i in range(rng[0], rng[1] + 1):
        t, V = loadFile(f"./DS{i:04}.CSV")
        fitResults.append(fitGaus(t, V))
        if plot:
            plotFit(fitResults[-1], t, V)
    return fitResults


def getAmps(lst: list[FitInfo]) -> list[tuple[float, float]]:
    return list(map(lambda x: (x.A, x.A_err), lst))


def plotFit(fit: FitInfo, t: list[float], V: list[float]):
    plt.figure()
    plt.plot(t, V)
    plt.plot(t, gauss(t, *fit.params()))
    plt.xlabel("Time (s)")
    plt.ylabel("Voltage (V)")
    plt.savefig(f"./figs/{fit.A:.2g}.png")
    return


def getSlope(
    inputs: np.ndarray, file_range: tuple, capacitance=1e-12
) -> tuple[float, float]:
    """Basically a wrapper for everything in the analysis notebook.

    Args:
        inputs (np.ndarray): Input in mV
        file_range (tuple): Number identifier range for files (a, b)
        capacitance (_type_, optional): Capacitance of test capacitor. Defaults to 1e-12.

    Returns:
        tuple: (slope, slope error)
    """
    results: list[FitInfo] = getFits(file_range)  # file range 1->16
    inputs = inputs * 1e-3 * capacitance * 1e12  # convert mV into charge (pC)
    amps = getAmps(results)  # get amplitude values from results
    amps, amps_std = np.transpose(amps)

    linear = lambda x, m, b: m * x + b
    p, cov = curve_fit(linear, inputs, amps, sigma=amps_std, p0=(3753861894698.39, 0))
    linerr = np.sqrt(np.diag(cov))
    return p[0], linerr[0]
