extern void _exit(int);

void _start(void)
{
    int a = 123, b = 456;
    int c = a + b;

    int assert_true = c == (123 + 456);

    _exit(!assert_true);
}
