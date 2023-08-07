def fit(x, a):
    return a*x


C = 1e-12 #F

def voltsToCharge(x: float) -> float:
    """Convert a voltage change into a charge bundle magnitude

    Args:
        x (float): Voltage (V)

    Returns:
        float: Charge (C)
    """
    return C*x


e = 1.60218e-19 #C   
def chargeToElectron(x: float) -> float:
    """Convert a charge value (C) into a number of electrons

    Args:
        x (float): Charge in Coulombs

    Returns:
        float: Number of electrons (not rounded)
    """
    return x / e


def chi_squared_reduced(data, model, sigma, dof=None):
    """
    Calculate the reduced chi-squared value for a fit.

    If no dof is given, returns the chi-squared (non-reduced) value.

    Parameters
    ----------
    data : array_like
        The observed data.
    model : array_like
        The model data.
    sigma : array_like
        The uncertainty in the data.
    dof : int
        Degrees of freedom (len(data) - # of free parameters).
    """
    sq_residual = (data - model)**2
    chi_sq = np.sum(sq_residual / sigma**2)
    if dof is None:
        return chi_sq
    else:
        nu = len(data) - dof
        return chi_sq / nu