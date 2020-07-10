public class NativeGL {
    // terminal tty
    public static native int is_a_tty();

    public static native int init();
    public static native void quit();

    public static native long create_window(byte[] title, int x, int y, int w, int h, int flags);
    public static native void destroy_window(long window);
}
