//

double call_ptr(double (*s)(double), double (*c)(double), double x)
{
    double sv = s(x);
    double cv = c(x);
    return sv * sv + cv * cv;
}
