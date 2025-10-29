def eval_poly(x: int, deg: int, A: list[int]) -> int:
    # Horner's rule
    rax: int = A[deg]
    for rcx in range(deg - 1, -1, -1):
        rax = rax * x + A[rcx]
    return rax

def main(args: list[str]) -> int:
    # .data
    xmsg = 'Please enter the value of x at which to evaluate: '
    degmsg = 'Please enter the degree of the polynomial: '
    apostmsg = ']: '
    amsg = 'Please enter a value for a['
    echomsg = "The number read was: "
    evalmsg = "The polynomial evaluated to: "
    a: list[int] = []

    # .start
    # int_to_str is the equivalent of int(input())
    x: int = int(input(xmsg))
    print(echomsg + str(x))

    deg: int = int(input(degmsg))
    print(echomsg + str(deg))

    # .read_loop
    for i in range(deg+1):
        a.append(int(input(amsg + str(i) + apostmsg)))

    rax = eval_poly(x, deg, a)
    print(evalmsg + str(rax))
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main([]))