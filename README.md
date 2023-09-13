# bwrapx

This is an extension of BubbleWrap [bwrap](https://github.com/containers/bubblewrap) frontend, which adds an ability to specify options in form of regular expressions.

## Usage

For example, the following invocation will bind all libraries matching the `/usr/lib/x86_64-linux-gnu/libz\..*` pattern to the same names within the container:

```
./bwrapx \
    --bind '/usr/lib/x86_64-linux-gnu/libz\..*' '\g<0>' -- bash -i
```

In order words, the command above will expand to the following `bwrap` command:

```
bwrap \
    --bind /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/x86_64-linux-gnu/libz.so \
    --bind /usr/lib/x86_64-linux-gnu/libz.so.1.2.11 /usr/lib/x86_64-linux-gnu/libz.so.1.2.11 \
    --bind /usr/lib/x86_64-linux-gnu/libz.a /usr/lib/x86_64-linux-gnu/libz.a \
    --bind /usr/lib/x86_64-linux-gnu/libz.so.1 /usr/lib/x86_64-linux-gnu/libz.so.1 -- bash -i
```

The result may vary, depending on the actual content of the filesystem, which brings additional flexibility to the binding settings of `bwrap`.

