︠b5ab93e7-0b31-45c3-ac2c-d7002d917a79r︠
import numpy as np
from sage.all import *


# ----------------------- Arithmetics ------------------------------

def add(x, y):

    return (x + y) % 257


def mul(x, y):

    return (x * y) % 257


def sub(x, y):

    return (x - y) % 257


def power(x, y):

    return (x ^ y) % 257


# ------------------------ Encoding -------------------------------

# Create a transpose of Vandermonde matrix
# size (k x n)
# k: Number of rows
# n: Number of columns

def create_matrix(k, n):
    A = []

    for i in range(k):
        temp_arr = []

        for j in range(n):
            temp_arr.append(power(j, i))

        A.append(temp_arr)

    return A


# Create coefficients array
# Change every symbol to his Ascii representation

def create_coef_arr(msg):
    M = [ord(m) for m in msg]

    return M


def matrix_mul(m1, m2, k, n):
    res = np.zeros(n, dtype=int)

    j = 0
    while j < n:
        s = 0
        for t in range(k):
            s = add(s, mul(m1[t], m2[t][j]))

        res[j] = s
        j += 1

    return res


# Assume: len(msg) = k
#         msg contains ascii characters
#         k <= n
#         (a_0, a_2, ... , a_n-1) == (0, 2, ... , n-1)

def encode(msg, n):
    k = len(msg)
    M = create_coef_arr(msg)
    A = create_matrix(k, n)

    RS_Code = matrix_mul(M, A, k, n)

    return RS_Code


# ------------------------ List_decoding -------------------------------

# Create the 'Q(X,Y) matrix'

def xy_matrix(a_arr, y_arr, n, deg_a, deg_y):
    A = []

    for i in range(n):
        temp_arr = []

        for j in range(deg_a):
            for t in range(deg_y):
                temp_arr.append(mul(power(a_arr[i], j), power(y_arr[i], t)))

        A.append(temp_arr)

    return A


# Return Q(X,Y) function

def get_q(a_arr, y_arr, n, deg_a, deg_y):
    deg_a += 1
    deg_y += 1

    M = MatrixSpace(GF(257), n, deg_a * deg_y)
    A = M(xy_matrix(a_arr, y_arr, n, deg_a, deg_y))

    num_of_column = deg_a * deg_y

    x = A.right_kernel_matrix(basis="computed")

    return x


# Generate polinomial given the coefficients array

def gen_poly(q_arr, deg_a, deg_y):
    deg_a += 1
    deg_y += 1
    x, y = PolynomialRing(GF(257), 2, ['x','y']).gens()

    f = 0

    for i in range(deg_a):
        for j in range(deg_y):
            k = deg_y*i+j
            g = q_arr[k]*x^i*y^j
            f += g

    return f


# Checks if the factor is in the form 'y-p(x)'

def check_factor(fact):
    res = False
    degrees = list(fact.dict())
    degrees = [tuple(f) for f in degrees]

    # Check if 'y' exists in the factor
    if (0, 1) in degrees:
        degrees = [i for i in degrees if i[0] != 0 or i[1] != 1]
        res = True

    # Check if y still exists in the factor
    # If exists, return false
    for d in degrees:
        if (d[1] >= 1):
            return False

    return res


# Creates a list of all factors in the form 'y-p(x)'
# Once found, removes the 'y' from it
# Returns a list of possible polynomials

def create_list(Q):
    L = []

    k = PolynomialRing(GF(257), 1 ,'y').gen()
    factors = [g[0] for g in list(Q.factor())]

    for fact in factors:
        if(check_factor(fact)):
            L.append((fact - k) * (-1))

    return L


# Returns list of polynomials

def list_decoding(encoded_msg, n, k):
    a_array = [i for i in range(n)]

    deg_a = int(math.sqrt(n * (k - 1)))
    deg_y = int(math.sqrt(n / (k - 1)))

    q_kernel = get_q(a_array, encoded_msg, n, deg_a, deg_y)
    q_kernel = [list(k) for k in q_kernel]

    q_array = [gen_poly(k, deg_a, deg_y) for k in q_kernel]

    f = []
    for q in q_array:
        f += create_list(q)

    f = list(set(f))

    f2 = []
    for poly in f:
        coef = poly.coefficients()
        if -1 not in coef:
            f2.append(poly)

    return f2


# Add noise/errors to message
# msg: Encoded message
# err: Number of errors to add

def add_errors(msg, err, n):
    err_msg = [m for m in msg]

    for i in range(err):
        e = randrange(257)
        if msg[i] != e:
            err_msg[i] = e
        else:
            err_msg[i] = add(e, 1)

    return err_msg


# Transforms the polynomial array into an array of strings
# Those are the possible codewords after decoding

def poly_to_str(poly_arr):
    decoded_msg_arr = []

    for f_i in poly_arr:
        coefs_array = f_i.coefficients()
        msg = [chr(c) for c in coefs_array]
        msg.reverse()
        decoded_msg_arr.append(''.join([str(elem) for elem in msg]))

    return decoded_msg_arr


# ------------------------ Main -------------------------------

# Printing the values for final result

def print_values(msg, enc_msg, enc_msg_err, dec_msg):
    print('Original message:'); print(msg)
    print('')
    print('Encoded message:'); print(enc_msg)
    print('')
    print('Encoded message with errors:'); print(np.array(enc_msg_err))
    print('')
    print('Output polynomials list:'); print(dec_msg)
    print('')
    print('Decoded codewords:'); print(poly_to_str(dec_msg))



# Receives the values from the tests
# Preforms the full RS code of encoding and decoding

def RS(msg, err, n):
    k = len(msg)

    encoded_msg = encode(msg, n)
    encoded_msg_with_errors = add_errors(encoded_msg, err, n)

    poly_list = list_decoding(encoded_msg_with_errors, n, k)

    print_values(msg, encoded_msg, encoded_msg_with_errors, poly_list)


# The main function
# Receives the values from the user
# Preforms the full RS code of encoding and decoding

def main():
    msg = str(raw_input("Message: "))
    n = int(raw_input('n: '))
    err = int(raw_input('Errors: '))

    RS(msg, err, n)


# ------------------------ Tests -------------------------------

def test1():
    print("\n------test1------\n")
    msg = "ab"
    err = 0
    n = 8

    RS(msg, err, n)


def test2():
    print("\n------test2------\n")
    msg = "bye"
    err = 0
    n = 12

    RS(msg, err, n)


def test3():
    print("\n------test3------\n")
    msg = "hello"
    err = 0
    n = 20

    RS(msg, err, n)


def test4():
    print("\n------test4------\n")
    msg = "cd"
    err = 2
    n = 8

    RS(msg, err, n)


def test5():
    print("\n------test5------\n")
    msg = "cd"
    err = 3
    n = 8

    RS(msg, err, n)


def test6():
    print("\n------test6------\n")
    msg = "cd"
    err = 4
    n = 8

    RS(msg, err, n)


def test7():
    print("\n------test7------\n")
    msg = "abc"
    err = 3
    n = 12

    RS(msg, err, n)


def test8():
    print("\n------test8------\n")
    msg = "abc"
    err = 4
    n = 12

    RS(msg, err, n)


def test9():
    print("\n------test9------\n")
    msg = "abc"
    err = 5
    n = 12

    RS(msg, err, n)


def test10():
    print("\n------test10------\n")
    msg = "abc"
    err = 24
    n = 40

    RS(msg, err, n)


def test11():
    print("\n------test11------\n")
    msg = "abc"
    err = 25
    n = 40

    RS(msg, err, n)


def test12():
    print("\n------test12------\n")
    msg = "abcde"
    err = 10
    n = 40

    RS(msg, err, n)


def test13():
    print("\n------test13------\n")
    msg = "abcde"
    err = 18
    n = 40

    RS(msg, err, n)


def test14():
    print("\n------test14------\n")
    msg = "abcde"
    err = 19
    n = 40

    RS(msg, err, n)


def test15():
    print("\n------test15------\n")
    msg = "ab"
    err = 10
    n = 72

    RS(msg, err, n)


def test16():
    print("\n------test16------\n")
    msg = "ab"
    err = 55
    n = 72

    RS(msg, err, n)


def test17():
    print("\n------test17------\n")
    msg = "ab"
    err = 56
    n = 72

    RS(msg, err, n)


def test18():
    print("\n------test18------\n")
    msg = "abcd"
    err = 10
    n = 100

    RS(msg, err, n)


def test19():
    print("\n------test19------\n")
    msg = "abcd"
    err = 69
    n = 100

    RS(msg, err, n)


def test20():
    print("\n------test20------\n")
    msg = "abcd"
    err = 70
    n = 100

    RS(msg, err, n)


def test21():
    print("\n------test21------\n")
    msg = "abcdefghij"
    err = 20
    n = 100

    RS(msg, err, n)


def test22():
    print("\n------test22------\n")
    msg = "abcdefghij"
    err = 48
    n = 100

    RS(msg, err, n)


def test23():
    print("\n------test23------\n")
    msg = "abcdefghij"
    err = 49
    n = 100

    RS(msg, err, n)

#------------------------ Running the tests ------------------------

def run_tests():
#     test1()
#     test2()
#     test3()
#     test4()
#     test5()
#     test6()
#     test7()
#     test8()
#     test9()
#     test10()
#     test11()
#     test12()
#     test13()
#     test14()
#     test15()
#     test16()
#     test17()
#     test18()
#     test19()
#     test20()
#     test21()
#     test22()
#     test23()
    return


# ------------------------ To Run ------------------------------

# Run main function (enter a case you want to test)
# Make sure all tests are commented in the run_tests() function before running the main
main()

# Run tests
# Comment the main() call and uncomment the relevant test before running it
# run_tests()


# ------------------------ Output ------------------------------
︡62cc972f-0d96-4ea2-8e2f-73fa05ed760f︡{"raw_input":{"prompt":"Message: "}}︡{"delete_last":true}︡{"raw_input":{"prompt":"Message: ","submitted":true,"value":"asdf"}}︡{"raw_input":{"prompt":"n: "}}









