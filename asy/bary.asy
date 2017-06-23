size(8cm);
pair A = dir(110);
pair B = dir(215);
pair C = dir(325);
real a = abs(B-C);
real b = abs(C-A);
real c = abs(A-B);
real s = (a+b+c)/2;

pair bary(real x, real y, real z) {
	real k = x+y+z;
	x /= k;
	y /= k;
	z /= k;
	return x*A + y*B + z*C;
}

real S_A = (b*b+c*c-a*a)/2;
real S_B = (c*c+a*a-b*b)/2;
real S_C = (a*a+b*b-c*c)/2;

dot("$A$", A, A);
dot("$B$", B, B);
dot("$C$", C, C);
